package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
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

// Пример списка продуктов
var groups = []Group{
	{ID: 1, Title: "Wolfmother", Description: "Wolfmother - австралийская рок-группа, образовавшаяся в Эрскинвилле, Сидней, в 2000 году и с 2004 года исполняющая хард-рок с элементами психоделики и стоунер-рока, основываясь на наследии конца 1960-х — начале 1970-х годов, прог-роке, гранже и нео-блюзе. Обладатель множества музыкальных наград, в том числе Грэмми за «Лучшее хард-рок исполнение» с синглом «Woman».", ImageURL: "https://i.pinimg.com/originals/2b/9a/b2/2b9ab2902e90dd5fef095f8b9fe7ab8f.jpg", Favourite: "true", Price: 1200, Quantity: 0},
	{ID: 2, Title: "Supergrass", Description: "Supergrass — британская группа альтернативного рока, образованная в 1993 году бывшими участниками инди-группы The Jennifers и получившая известность на волне брит-попа в 1995—1996 годах. Квартет с фронтменом Гэзом Кумбзом во главе начал своё восхождение с быстрых, запоминающихся поп-панк-синглов, соединив в своём раннем творчестве (согласно Allmusic) влияния — с одной стороны Buzzcocks, The Jam и Madness, с другой — мод-рока (The Kinks, The Small Faces) и глэма (T. Rex). В последующие годы музыка Supergrass усложнялась и смягчалась, наполянясь нео-психоделическими и позднебитловскими мотивами. Группа становилась лауреатом Ivor Novello и Mercury Prize, трижды получала Brit Awards.", ImageURL: "https://i.pinimg.com/originals/d3/75/0a/d3750a91f6e83e0ed4785d35505aaff1.jpg", Favourite: "true", Price: 1000, Quantity: 0},
	{ID: 3, Title: "Radiohead", Description: "Radiohead — британская рок-группа из Оксфордшира. Группа была основана в 1985 году, и её состав с того времени не менялся. Стиль Radiohead традиционно определяют как альтернативный рок, хотя на разных этапах звучание варьировалось от брит-попа до арт-рока и электронной музыки.", ImageURL: "https://a.d-cd.net/78041a2s-960.jpg", Favourite: "false", Price: 2165, Quantity: 0},
	{ID: 4, Title: "Maximum the Hormone", Description: "Maximum The Hormone — японская хэви-метал группа из Хатиодзи, Токио. С 1999 года их состав состоит из вокалиста Дайсукэ-хана, барабанщицы Нао, гитариста Maximum the Ryo-kun и басиста Уэ-тян. Каждый участник поочередно исполняет ведущий вокал, часто в рамках одной и той же песни, за исключением Ю-тяна, который почти исключительно исполняет бэк-вокал.", ImageURL: "http://img1.ak.crunchyroll.com/i/spire3/88b10b65d7e9b541af2bd153bd2e14d31480687960_full.jpg", Favourite: "false", Price: 1768, Quantity: 2},
	{ID: 5, Title: "(K)now Name", Description: "(K)now Name — японская музыкальная группа, сотрудничающая с лейблом Toho Animation Records. Была сформирована в 2016 году и занимается созданием саундтреков к аниме-сериалам.", ImageURL: "https://39s-a.musify.club/img/71/20488847/52531513.jpg", Favourite: "false", Price: 1456, Quantity: 0},
	{ID: 6, Title: "Король и Шут", Description: "«Король и Шут» — советская и российская хоррор-панк-группа из Санкт-Петербурга. Группа была образована в Ленинграде в 1988 году. После смерти её лидера и одного из основателей Михаила Горшенёва 19 июля 2013 года выступает только в рок-мюзикле TODD. Выделяется своим необычным для классического панк-рока стилем. Песни группы представляют собой небольшие законченные истории, часто в фэнтезийном, мистическом, а также историческом и ужасающем ключе. Сценический имидж группы постоянно менялся и часто включал в себя грим, соответствующий тематике песен. В прессе группа неоднократно обозначалась как «культовая»", ImageURL: "https://plastinka.com/files/modules/artists/7720/common/photo_large-kish2.jpg", Favourite: "false", Price: 3664, Quantity: 0},
	{ID: 7, Title: "Skillet", Description: "Skillet — американская христианская рок-группа из города Мемфис, штат Теннесси, основанная в 1996 году. На данный момент группой выпущено одиннадцать студийных альбомов, четыре EP и два концертных альбома", ImageURL: "https://i.pinimg.com/736x/c8/ea/7a/c8ea7a217572ef26833161b8dd10a028.jpg", Favourite: "false", Price: 1235, Quantity: 0},
}

// обработчик для GET-запроса, возвращает список продуктов
func getGroupsHandler(w http.ResponseWriter, r *http.Request) {
	// Устанавливаем заголовки для правильного формата JSON
	w.Header().Set("Content-Type", "application/json")
	// Преобразуем список заметок в JSON
	json.NewEncoder(w).Encode(groups)
}

func getFavouritesHandler(w http.ResponseWriter, r *http.Request) {
	var g = []Group{}
	// Устанавливаем заголовки для правильного формата JSON
	w.Header().Set("Content-Type", "application/json")
	// Преобразуем список заметок в JSON
	for _, group := range groups {
		if group.Favourite == "true" {
			g = append(g, group)
		}
	}
	json.NewEncoder(w).Encode(g)
}

func getCartHandler(w http.ResponseWriter, r *http.Request) {
	var g = []Group{}
	// Устанавливаем заголовки для правильного формата JSON
	w.Header().Set("Content-Type", "application/json")
	// Преобразуем список заметок в JSON
	for _, group := range groups {
		if group.Quantity != 0 {
			g = append(g, group)
		}
	}
	json.NewEncoder(w).Encode(g)
}

// обработчик для POST-запроса, добавляет продукт
func createGroupHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	var newGroup Group
	err := json.NewDecoder(r.Body).Decode(&newGroup)
	if err != nil {
		fmt.Println("Error decoding request body:", err)
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	fmt.Printf("Received new group: %+v\n", newGroup)
	var lastID int = len(groups)

	for _, groupItem := range groups {
		if groupItem.ID > lastID {
			lastID = groupItem.ID
		}
	}
	newGroup.ID = lastID + 1
	groups = append(groups, newGroup)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(newGroup)
}

//Добавление маршрута для получения одного продукта

func getGroupByIDHandler(w http.ResponseWriter, r *http.Request) {
	// Получаем ID из URL
	idStr := r.URL.Path[len("/groups/"):]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid group ID", http.StatusBadRequest)
		return
	}

	// Ищем продукт с данным ID
	for _, group := range groups {
		if group.ID == id {
			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(group)
			return
		}
	}

	// Если продукт не найден
	http.Error(w, "group not found", http.StatusNotFound)
}

// удаление продукта по id
func deleteGroupHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodDelete {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Получаем ID из URL
	idStr := r.URL.Path[len("/groups/delete/"):]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid group ID", http.StatusBadRequest)
		return
	}

	// Ищем и удаляем продукт с данным ID
	for i, group := range groups {
		if group.ID == id {
			// Удаляем продукт из среза
			groups = append(groups[:i], groups[i+1:]...)
			w.WriteHeader(http.StatusNoContent) // Успешное удаление, нет содержимого
			return
		}
	}

	// Если продукт не найден
	http.Error(w, "group not found", http.StatusNotFound)
}

// Обновление продукта по id
func updateGroupHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		http.Error(w, "Invalid request method", http.StatusMethodNotAllowed)
		return
	}

	// Получаем ID из URL
	idStr := r.URL.Path[len("/groups/update/"):]
	id, err := strconv.Atoi(idStr)
	if err != nil {
		http.Error(w, "Invalid group ID", http.StatusBadRequest)
		return
	}

	// Декодируем обновлённые данные продукта
	var updatedGroup Group
	err = json.NewDecoder(r.Body).Decode(&updatedGroup)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Ищем продукт для обновления
	for i, group := range groups {
		if group.ID == id {

			groups[i].ImageURL = updatedGroup.ImageURL
			groups[i].Title = updatedGroup.Title
			groups[i].Description = updatedGroup.Description
			groups[i].Price = updatedGroup.Price
			groups[i].Favourite = updatedGroup.Favourite
			groups[i].Quantity = updatedGroup.Quantity

			w.Header().Set("Content-Type", "application/json")
			json.NewEncoder(w).Encode(groups[i])
			return
		}
	}

	// Если продукт не найден
	http.Error(w, "group not found", http.StatusNotFound)
}

func main() {
	http.HandleFunc("/groups", getGroupsHandler)           // Получить все продукты
	http.HandleFunc("/groups/create", createGroupHandler)  // Создать продукт
	http.HandleFunc("/groups/", getGroupByIDHandler)       // Получить продукт по ID
	http.HandleFunc("/groups/update/", updateGroupHandler) // Обновить продукт
	http.HandleFunc("/groups/delete/", deleteGroupHandler)
	http.HandleFunc("/groups/favourites", getFavouritesHandler)
	http.HandleFunc("/groups/cart", getCartHandler)
	fmt.Println("Server is running on port 8080!")
	http.ListenAndServe(":8080", nil)
}
