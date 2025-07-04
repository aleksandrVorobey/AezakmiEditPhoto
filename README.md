# АezakmiEditPhoto

Тестовое приложение для авторизации и редактирования фотографий.

Использовался SwiftUI и архитектурный паттерн MVVM. Для авторизации используется Firebase/Auth, для входа через Google – Google SignIn SDK. Для редактирования фотографий используется Core Image, PencilKit и Photos Framework.

## В приложении реализовано

### 1. Авторизация пользователей
- Регистрация и вход по email и паролю, а также авторизация через Google.
    - Подтверждение учетной записи и запрос повторного подтверждения.
    - Сброс пароля через функцию "Забыли пароль".

### 2. Редактирование фотографий
- Загрузка изображения для редактирования с медиатеки или из камеры.
- В режиме редактирования изображения:
    - Рисование с помощью PencilKit.
    - Поворот изображения.
    - Наложение текста (с возможностью изменения цвета, шрифта и размера).
    - Применение фильтров.
- Сохранение отредактированного изображения и возврат на главный экран.
- Отредактированное изображение можно сохранить в медиатеку или расшарить.
