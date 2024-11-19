# MyTodoList - Test task for review
<br />

<p align="row">
<img src= "https://github.com/Mutagrey/MyToDoList/blob/main/Screenshots/screen1.jpeg" width="272" >
<img src= "https://github.com/Mutagrey/MyToDoList/blob/main/Screenshots/screen2.jpeg" width="272" >
<img src= "https://github.com/Mutagrey/MyToDoList/blob/main/Screenshots/screen3.png" width="272" >
<img src= "https://github.com/Mutagrey/MyToDoList/blob/main/Screenshots/screen4.png" width="272" >
<img src= "https://github.com/Mutagrey/MyToDoList/blob/main/Screenshots/screen5.png" width="272" >
</p>

## Требования:
1. Список задач:
- Отображение списка задач на главном экране.
- Задача должна содержать название, описание, дату создания и статус (выполнена/не
выполнена).
- Возможность добавления новой задачи.
- Возможность редактирования существующей задачи.
- Возможность удаления задачи.
- Возможность поиска по задачам.

2. Загрузка списка задач из dummyjson api: <a href="https://dummyjson.com/todos"/>. При первом
запуске приложение должно загрузить список задач из указанного json api.

3. Многопоточность:
- Обработка создания, загрузки, редактирования, удаления и поиска задач должна
выполняться в фоновом потоке с использованием GCD или NSOperation.
- Интерфейс не должен блокироваться при выполнении операций.

4. CoreData:
- Данные о задачах должны сохраняться в CoreData.
- Приложение должно корректно восстанавливать данные при повторном запуске.

5. Используйте систему контроля версий GIT для разработки.

6. Напишите юнит-тесты для основных компонентов приложения

**Будет бонусом**:

7. Архитектура VIPER: Приложение должно быть построено с использованием
архитектуры VIPER. Каждый модуль должен быть четко разделен на компоненты: View,
Interactor, Presenter, Entity, Router.

## Requirements

- iOS 17.0+
- Xcode 15.0+

## Meta

Sergey Petrov  – mutagrey@yandex.ru

Free to use.
