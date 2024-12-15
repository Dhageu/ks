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

/*var groups = []Group{
	{ID: 1, Title: "Wolfmother", Description: "Wolfmother - австралийская рок-группа, образовавшаяся в Эрскинвилле, Сидней, в 2000 году и с 2004 года исполняющая хард-рок с элементами психоделики и стоунер-рока, основываясь на наследии конца 1960-х — начале 1970-х годов, прог-роке, гранже и нео-блюзе. Обладатель множества музыкальных наград, в том числе Грэмми за «Лучшее хард-рок исполнение» с синглом «Woman».", ImageURL: "https://i.pinimg.com/originals/2b/9a/b2/2b9ab2902e90dd5fef095f8b9fe7ab8f.jpg", Favourite: "true", Price: 1200, Quantity: 0},
	{ID: 2, Title: "Supergrass", Description: "Supergrass — британская группа альтернативного рока, образованная в 1993 году бывшими участниками инди-группы The Jennifers и получившая известность на волне брит-попа в 1995—1996 годах. Квартет с фронтменом Гэзом Кумбзом во главе начал своё восхождение с быстрых, запоминающихся поп-панк-синглов, соединив в своём раннем творчестве (согласно Allmusic) влияния — с одной стороны Buzzcocks, The Jam и Madness, с другой — мод-рока (The Kinks, The Small Faces) и глэма (T. Rex). В последующие годы музыка Supergrass усложнялась и смягчалась, наполянясь нео-психоделическими и позднебитловскими мотивами. Группа становилась лауреатом Ivor Novello и Mercury Prize, трижды получала Brit Awards.", ImageURL: "https://i.pinimg.com/originals/d3/75/0a/d3750a91f6e83e0ed4785d35505aaff1.jpg", Favourite: "true", Price: 1000, Quantity: 0},
	{ID: 3, Title: "Radiohead", Description: "Radiohead — британская рок-группа из Оксфордшира. Группа была основана в 1985 году, и её состав с того времени не менялся. Стиль Radiohead традиционно определяют как альтернативный рок, хотя на разных этапах звучание варьировалось от брит-попа до арт-рока и электронной музыки.", ImageURL: "https://a.d-cd.net/78041a2s-960.jpg", Favourite: "false", Price: 2165, Quantity: 0},
	{ID: 4, Title: "Maximum the Hormone", Description: "Maximum The Hormone — японская хэви-метал группа из Хатиодзи, Токио. С 1999 года их состав состоит из вокалиста Дайсукэ-хана, барабанщицы Нао, гитариста Maximum the Ryo-kun и басиста Уэ-тян. Каждый участник поочередно исполняет ведущий вокал, часто в рамках одной и той же песни, за исключением Ю-тяна, который почти исключительно исполняет бэк-вокал.", ImageURL: "http://img1.ak.crunchyroll.com/i/spire3/88b10b65d7e9b541af2bd153bd2e14d31480687960_full.jpg", Favourite: "false", Price: 1768, Quantity: 2},
	{ID: 5, Title: "(K)now Name", Description: "(K)now Name — японская музыкальная группа, сотрудничающая с лейблом Toho Animation Records. Была сформирована в 2016 году и занимается созданием саундтреков к аниме-сериалам.", ImageURL: "https://39s-a.musify.club/img/71/20488847/52531513.jpg", Favourite: "false", Price: 1456, Quantity: 0},
	{ID: 6, Title: "Король и Шут", Description: "«Король и Шут» — советская и российская хоррор-панк-группа из Санкт-Петербурга. Группа была образована в Ленинграде в 1988 году. После смерти её лидера и одного из основателей Михаила Горшенёва 19 июля 2013 года выступает только в рок-мюзикле TODD. Выделяется своим необычным для классического панк-рока стилем. Песни группы представляют собой небольшие законченные истории, часто в фэнтезийном, мистическом, а также историческом и ужасающем ключе. Сценический имидж группы постоянно менялся и часто включал в себя грим, соответствующий тематике песен. В прессе группа неоднократно обозначалась как «культовая»", ImageURL: "https://plastinka.com/files/modules/artists/7720/common/photo_large-kish2.jpg", Favourite: "false", Price: 3664, Quantity: 0},
	{ID: 7, Title: "Skillet", Description: "Skillet — американская христианская рок-группа из города Мемфис, штат Теннесси, основанная в 1996 году. На данный момент группой выпущено одиннадцать студийных альбомов, четыре EP и два концертных альбома", ImageURL: "https://i.pinimg.com/736x/c8/ea/7a/c8ea7a217572ef26833161b8dd10a028.jpg", Favourite: "false", Price: 1235, Quantity: 0},
}*/

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

/*func getGroupsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	vars := mux.Vars(r)
	userID := vars["user_id"]
	fmt.Println("Received userID:", userID)

	rows, err := db.Query("SELECT * FROM groups ORDER BY id") // Запрос к БД
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
		//http.Error(w, "No groups found for the given user_id", http.StatusNotFound)
		return
	}

	json.NewEncoder(w).Encode(groups) // Отправка данных клиенту
}*/

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
