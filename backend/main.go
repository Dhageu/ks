package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
	_ "github.com/lib/pq"
)

// group представляет продукт
type Group struct {
	ID          int
	Title       string
	Description string
	ImageURL    string
	Favourite   string
	Price       int
	Quantity    int
}

var db *sql.DB

func initDB() {
	var err error
	connStr := "host=localhost port=5432 user=db_user password=password dbname=groupdb sslmode=disable"
	db, err = sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Ошибка подключения к базе данных:", err)
	}

	// Проверка соединения
	err = db.Ping()
	if err != nil {
		log.Fatal("База данных недоступна:", err)
	}

	fmt.Println("Успешное подключение к базе данных PostgreSQL")
}

func getGroupsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	rows, err := db.Query("SELECT id, title, description, image_url, favourite, price, quantity FROM groups ORDER BY id") // Запрос к БД
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var groups []Group
	for rows.Next() {
		var g Group
		if err := rows.Scan(&g.ID, &g.Title, &g.Description, &g.ImageURL, &g.Favourite, &g.Price, &g.Quantity); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		groups = append(groups, g)
	}

	json.NewEncoder(w).Encode(groups) // Отправка данных клиенту
}

func getFavouritesHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	vars := mux.Vars(r)
	userID := vars["user_id"]

	if userID == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	rows, err := db.Query("SELECT g.id, g.title, g.description, g.image_url, g.favourite, g.price, g.quantity FROM groups g INNER JOIN favourites f ON g.id = f.group_id WHERE f.user_id = $1 ORDER BY id", userID) // Запрос к БД
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var groups []Group
	for rows.Next() {
		var g Group
		if err := rows.Scan(&g.ID, &g.Title, &g.Description, &g.ImageURL, &g.Favourite, &g.Price, &g.Quantity); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		groups = append(groups, g)
	}
	if len(groups) == 0 {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode([]Group{})
		return
	}
	json.NewEncoder(w).Encode(groups)
}

func getCartHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	vars := mux.Vars(r)
	userID := vars["user_id"]

	if userID == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	rows, err := db.Query("SELECT g.id, g.title, g.description, g.image_url, g.favourite, g.price, c.quantity FROM groups g INNER JOIN cart c ON g.id = c.group_id WHERE c.user_id = $1 ORDER BY id", userID) // Запрос к БД
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	var groups []Group
	for rows.Next() {
		var g Group
		if err := rows.Scan(&g.ID, &g.Title, &g.Description, &g.ImageURL, &g.Favourite, &g.Price, &g.Quantity); err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		groups = append(groups, g)
	}
	if len(groups) == 0 {
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode([]Group{})
		return
	}
	json.NewEncoder(w).Encode(groups)
}

func updateGroupHandler(w http.ResponseWriter, r *http.Request) {
	// Разрешаем только PUT-метод
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	vars := mux.Vars(r)
	idStr := vars["index"]
	if idStr == "" {
		http.Error(w, "Index required", http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idStr)

	if err != nil {
		http.Error(w, "Invalid index", http.StatusBadRequest)
		return
	}

	// Декодируем обновлённые данные группы
	var updatedGroup Group
	err = json.NewDecoder(r.Body).Decode(&updatedGroup)
	if err != nil {
		http.Error(w, "Invalid JSON data: "+err.Error(), http.StatusBadRequest)
		return
	}

	// Выполняем SQL-запрос для обновления группы по ID
	query := `
        UPDATE groups 
        SET title = $1, description = $2, image_url = $3, favourite = $4, price = $5, quantity = $6
        WHERE id = $7 
        RETURNING id, title, description, image_url, favourite, price, quantity
    `
	var group Group
	err = db.QueryRow(
		query,
		updatedGroup.Title,
		updatedGroup.Description,
		updatedGroup.ImageURL,
		updatedGroup.Favourite,
		updatedGroup.Price,
		updatedGroup.Quantity,
		id,
	).Scan(
		&group.ID,
		&group.Title,
		&group.Description,
		&group.ImageURL,
		&group.Favourite,
		&group.Price,
		&group.Quantity,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			// Если группа с таким ID не найдена
			http.Error(w, "Group not found", http.StatusNotFound)
		} else {
			// Обработка других ошибок
			http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		}
		return
	}

	// Устанавливаем заголовок и отправляем обновлённую группу в JSON-формате
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(group); err != nil {
		http.Error(w, "Error encoding JSON: "+err.Error(), http.StatusInternalServerError)
		return
	}
}

func getGroupByIDHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	idStr := vars["index"]
	if idStr == "" {
		http.Error(w, "Index required", http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid index", http.StatusBadRequest)
		return
	}
	// Выполняем запрос к базе данных для поиска группы по ID
	var group Group
	err = db.QueryRow("SELECT id, title, description, image_url, favourite, price, quantity FROM groups WHERE id = $1", id).Scan(&group.ID, &group.Title, &group.Description, &group.ImageURL, &group.Favourite, &group.Price, &group.Quantity)

	if err != nil {
		if err == sql.ErrNoRows {
			// Если группа с таким ID не найдена
			http.Error(w, "Group not found", http.StatusNotFound)
		} else {
			// Если произошла другая ошибка
			http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		}
		return
	}

	// Устанавливаем заголовки ответа для правильного формата JSON
	w.Header().Set("Content-Type", "application/json")

	// Отправляем найденную группу в формате JSON
	if err := json.NewEncoder(w).Encode(group); err != nil {
		http.Error(w, "Error encoding JSON: "+err.Error(), http.StatusInternalServerError)
		return
	}
}

func createGroupHandler(w http.ResponseWriter, r *http.Request) {
	// Разрешаем только POST-метод
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Декодируем данные новой группы из тела запроса
	var newGroup Group
	err := json.NewDecoder(r.Body).Decode(&newGroup)
	if err != nil {
		fmt.Println("Error decoding request body:", err)
		http.Error(w, "Invalid JSON data: "+err.Error(), http.StatusBadRequest)
		return
	}

	// SQL-запрос для вставки новой группы и возврата созданной записи
	query := `
        INSERT INTO groups (id, title, description, image_url, favourite, price, quantity)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING id, title, description, image_url, favourite, price, quantity
    `

	// Создаём структуру для результата
	var createdGroup Group
	err = db.QueryRow(
		query,
		newGroup.ID,
		newGroup.Title,
		newGroup.Description,
		newGroup.ImageURL,
		newGroup.Favourite,
		newGroup.Price,
		newGroup.Quantity,
	).Scan(
		&createdGroup.ID,
		&createdGroup.Title,
		&createdGroup.Description,
		&createdGroup.ImageURL,
		&createdGroup.Favourite,
		&createdGroup.Price,
		&createdGroup.Quantity,
	)

	if err != nil {
		fmt.Println("Error inserting group into database:", err)
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Устанавливаем заголовок и отправляем созданную группу клиенту
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(createdGroup); err != nil {
		http.Error(w, "Error encoding JSON: "+err.Error(), http.StatusInternalServerError)
		return
	}

	fmt.Printf("Successfully created group: %+v\n", createdGroup)
}

func addFavHandler(w http.ResponseWriter, r *http.Request) {
	// Установка заголовков
	w.Header().Set("Content-Type", "application/json")

	// Получение user_id из URL
	vars := mux.Vars(r)
	userID := vars["user_id"]

	if userID == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	// Чтение id из тела запроса
	var requestData struct {
		ID int `json:"id"` // Читаем поле "id" из тела запроса
	}

	// Декодируем тело запроса
	if err := json.NewDecoder(r.Body).Decode(&requestData); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	fmt.Printf("Received userID: %s, Group ID: %d\n", userID, requestData.ID)

	// Выполняем SQL-запрос для добавления в избранное
	query := `
        INSERT INTO favourites (user_id, group_id) 
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING` // Игнорировать дубликаты, если уже существует

	_, err := db.Exec(query, userID, requestData.ID)
	if err != nil {
		http.Error(w, "Failed to add favourite: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Ответ клиенту
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Favourites changed!",
	})
}

func addCartHandler(w http.ResponseWriter, r *http.Request) {
	// Установка заголовков
	w.Header().Set("Content-Type", "application/json")

	// Получение user_id из URL
	vars := mux.Vars(r)
	userID := vars["user_id"]

	if userID == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	// Чтение id из тела запроса
	var requestData struct {
		ID int `json:"id"` // Читаем поле "id" из тела запроса
	}

	// Декодируем тело запроса
	if err := json.NewDecoder(r.Body).Decode(&requestData); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	fmt.Printf("Received userID: %s, Group ID: %d\n", userID, requestData.ID)

	// Выполняем SQL-запрос для добавления в избранное
	query := `
        INSERT INTO cart (group_id, user_id, quantity) 
        VALUES ($1, $2, 1)
        ON CONFLICT DO NOTHING` // Игнорировать дубликаты, если уже существует

	_, err := db.Exec(query, requestData.ID, userID)
	if err != nil {
		http.Error(w, "Failed to add cart item: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Ответ клиенту
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(map[string]string{
		"message": "Cart changed!",
	})
}

func deleteFavHandler(w http.ResponseWriter, r *http.Request) {
	// Установка заголовков
	w.Header().Set("Content-Type", "application/json")

	// Получение user_id из URL
	vars := mux.Vars(r)
	userID := vars["user_id"]

	if userID == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	// Чтение id из тела запроса
	var requestData struct {
		ID int `json:"id"` // Читаем поле "id" из тела запроса
	}

	// Декодируем тело запроса
	if err := json.NewDecoder(r.Body).Decode(&requestData); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	fmt.Printf("Received userID: %s, Group ID: %d\n", userID, requestData.ID)

	// Выполняем SQL-запрос для добавления в избранное
	query := `
        DELETE FROM favourites WHERE user_id = $1 AND group_id = $2` // Игнорировать дубликаты, если уже существует

	result, err := db.Exec(query, userID, requestData.ID)
	if err != nil {
		http.Error(w, "Error deleting group: "+err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, "Error checking rows affected: "+err.Error(), http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		// Если ни одна строка не была удалена, возвращаем ошибку 404
		http.Error(w, "Favourite not found", http.StatusNotFound)
		return
	}

	// Если всё успешно, возвращаем статус 204 (No Content)
	w.WriteHeader(http.StatusNoContent)
}

func deleteCartHandler(w http.ResponseWriter, r *http.Request) {
	// Установка заголовков
	w.Header().Set("Content-Type", "application/json")

	// Получение user_id из URL
	vars := mux.Vars(r)
	userID := vars["user_id"]

	if userID == "" {
		http.Error(w, "User ID is required", http.StatusBadRequest)
		return
	}

	// Чтение id из тела запроса
	var requestData struct {
		ID int `json:"id"` // Читаем поле "id" из тела запроса
	}

	// Декодируем тело запроса
	if err := json.NewDecoder(r.Body).Decode(&requestData); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}

	fmt.Printf("Received userID: %s, Group ID: %d\n", userID, requestData.ID)

	// Выполняем SQL-запрос для добавления в избранное
	query := `
        DELETE FROM cart WHERE user_id = $1 AND group_id = $2`

	result, err := db.Exec(query, userID, requestData.ID)
	if err != nil {
		http.Error(w, "Error deleting group: "+err.Error(), http.StatusInternalServerError)
		return
	}

	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, "Error checking rows affected: "+err.Error(), http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		// Если ни одна строка не была удалена, возвращаем ошибку 404
		http.Error(w, "Cart item not found", http.StatusNotFound)
		return
	}

	// Если всё успешно, возвращаем статус 204 (No Content)
	w.WriteHeader(http.StatusNoContent)
}

func deleteGroupHandler(w http.ResponseWriter, r *http.Request) {
	// Проверка метода запроса
	if r.Method != http.MethodDelete {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	vars := mux.Vars(r)
	idStr := vars["index"]

	if idStr == "" {
		http.Error(w, "Index is required", http.StatusBadRequest)
		return
	}

	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid index", http.StatusBadRequest)
		return
	}

	// SQL-запрос для удаления группы по ID
	query := "DELETE FROM groups WHERE id = $1"
	result, err := db.Exec(query, id)
	if err != nil {
		http.Error(w, "Error deleting group: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Проверяем, была ли удалена хотя бы одна строка
	rowsAffected, err := result.RowsAffected()
	if err != nil {
		http.Error(w, "Error checking rows affected: "+err.Error(), http.StatusInternalServerError)
		return
	}

	if rowsAffected == 0 {
		// Если ни одна строка не была удалена, возвращаем ошибку 404
		http.Error(w, "Group not found", http.StatusNotFound)
		return
	}

	// Если всё успешно, возвращаем статус 204 (No Content)
	w.WriteHeader(http.StatusNoContent)
}

func updateQuantityHandler(w http.ResponseWriter, r *http.Request) {
	// Разрешаем только PUT-метод
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	vars := mux.Vars(r)
	userID := vars["user_id"]
	if userID == "" {
		http.Error(w, "Index required", http.StatusBadRequest)
		return
	}

	// Декодируем обновлённые данные группы
	var updatedQuantity struct {
		ID       int `json:"ID"`
		Quantity int `json:"Quantity"`
	}
	err := json.NewDecoder(r.Body).Decode(&updatedQuantity)
	if err != nil {
		http.Error(w, "Invalid JSON data: "+err.Error(), http.StatusBadRequest)
		return
	}

	// Выполняем SQL-запрос для обновления группы по ID
	query := `
        UPDATE cart 
        SET quantity = $1
		WHERE user_id = $2 AND group_id = $3
        RETURNING cart_id, group_id, user_id, quantity
    `

	var updatedCart struct {
		CartID   int    `json:"cart_id"`
		GroupID  int    `json:"group_id"`
		UserID   string `json:"user_id"`
		Quantity int    `json:"quantity"`
	}

	err = db.QueryRow(
		query,
		updatedQuantity.Quantity,
		userID,
		updatedQuantity.ID,
	).Scan(
		&updatedCart.CartID,
		&updatedCart.GroupID,
		&updatedCart.UserID,
		&updatedCart.Quantity,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			// Если группа с таким ID не найдена
			http.Error(w, "Cart item not found", http.StatusNotFound)
		} else {
			// Обработка других ошибок
			http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		}
		return
	}

	// Устанавливаем заголовок и отправляем обновлённую группу в JSON-формате
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(updatedCart); err != nil {
		http.Error(w, "Error encoding JSON: "+err.Error(), http.StatusInternalServerError)
		return
	}
}

func main() {
	initDB()
	r := mux.NewRouter()

	r.HandleFunc("/groups/favourites/{user_id}/add", addFavHandler).Methods("POST")
	r.HandleFunc("/groups/favourites/{user_id}/delete", deleteFavHandler).Methods("DELETE")

	r.HandleFunc("/groups/cart/{user_id}/update", updateQuantityHandler).Methods("PUT")
	r.HandleFunc("/groups/cart/{user_id}/add", addCartHandler).Methods("POST")
	r.HandleFunc("/groups/cart/{user_id}/delete", deleteCartHandler).Methods("DELETE")

	r.HandleFunc("/groups/favourites/{user_id}", getFavouritesHandler).Methods("GET") // Получить все продукты
	r.HandleFunc("/groups/update/{index}", updateGroupHandler).Methods("PUT")         // Обновить продукт
	r.HandleFunc("/groups/cart/{user_id}", getCartHandler).Methods("GET")
	r.HandleFunc("/groups/delete/{index}", deleteGroupHandler).Methods("DELETE")

	r.HandleFunc("/groups/create", createGroupHandler).Methods("POST")

	r.HandleFunc("/groups/{index}", getGroupByIDHandler).Methods("GET") // Создать продукт

	http.HandleFunc("/groups", getGroupsHandler)

	http.Handle("/", r)
	fmt.Println("Server is running on port 8080!")
	http.ListenAndServe(":8080", nil)
}
