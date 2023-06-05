# SigmaSDK - iOS

Sigma - это платформа для экспериментов, которая позволяет вам быстро оценивать влияние новых функций и предлагать продукты, которые нравятся вашим клиентам.

Требования
- iOS 11+

## Установка SDK

### Cocoapods

Если ваш проект использует Cocoapods, добавьте зависимость `SigmaSDK` в `Podfile`:

```
use_frameworks!
target 'MyApp' do
    pod 'SigmaSDK', '~> X.Y.Z'
    # ...
end
```

### Swift Package Manager

Если ваш проект использует Swift Package Manager, добавьте пакет `SigmaSDK` через `Xcode`:

File > Add Package > Search or Enter Package URL > https://github.com/expfdev/sigma_ios

Или вручную в файле `Package.swift`:

```
dependencies: [
    .package(url: "https://github.com/expfdev/sigma_ios"),
],
targets: [
    .target(name: "MyApp", dependencies: ["SigmaSDK"])
],
```

## Работа с SDK

### Инициализация SDK

Для работы с SDK необходимо создать объект типа `SigmaUser`. Он хранит информацию о пользователе, такую как его уникальный идентификатор.

Пример создания объекта `SigmaUser`:

```swift
import SigmaSDK

let user = SigmaUser.Builder()
    .setUserId("123")
    .setCustomProperty(true, key: "isAuthorized")
    .setEmail("user123@expf.ru")
    .build()
```

`SigmaUser.Builder` обладает следующими методами:

- `func setUserId(_ id: String) -> SigmaUser.Builder` - назначение ID анонимного пользователя. Используется для раздачи экспериментов и фича-флагов. (если не назначен, то не будет работать сплит экспериментов по userId).
- `func setProfileId(_ id: String) -> SigmaUser.Builder` - назначение ID авторизованного пользователя (например, в личном кабинете). (если не назначен, то не будет работать сплит экспериментов по profileId).
- `func setEmail(_ email: String) -> SigmaUser.Builder` - назначение параметра пользователя с названием `email`.
- `func setCustomProperty<Value: CustomStringConvertible>(_ value: Value, key: String) -> SigmaUser.Builder` - назначение custom-параметра пользователя (все названия таких параметров имеют префикс custom.).

После создания объекта `SigmaUser`, необходимо вызывать метод инициализации SDK:

```swift
import SigmaSDK

do {
    let client = try Sigma.initializeClient(projectToken: token, initialUser: user)
} catch let error {
    // Handle error
}
```

Метод `initializeClient` обладает следующими параметрами:

- `projectToken: String` - токен проекта (указан в панели управления).
- `initialUser: SigmaUser?` - Объект `SigmaUser`. Необязательный параметр. При отсутствии, SDK автоматически создаст объект `SigmaUser`, сгенерировав ему случайный идентификатор.
- `cacheTTL: UInt` - частота (в секундах) запрашивания конфигурации из сети. Необязательный параметр. По умолчанию равен 10 секундам.
- `retryCount: UInt` -  количество повторных попыток запрашивания конфигурации при неудачном запросе. Необязательный параметр. По умолчанию равен 3.
- `tag: String` - тег клиента Sigma. Необязательный параметр. По умолчанию равен "default". Необходим для создания нескольких экземпляров SigmaClient.

Для получения клиента `SigmaClient` используется метод `Sigma.getClient(tag: String)`.
Для завершения работы над клиентом используется метод `Sigma.removeClient(tag: String)`

При инициализации уже инициализированного клиента (с уже существующим тегом) будет выброшена ошибка `SigmaError.initializationOfExistingClient`.

### Получение значений Feature Flag

Для получения значений Feature Flag используются следующие методы `SigmaClient`:

```swift
func checkFlag<T: SigmaPropertyType>(flagName: String, onSuccess: SigmaSuccessCallback<T?>?, onError: SigmaErrorCallback?)
func checkFlag<T: SigmaPropertyType>(flagName: String) async throws -> T?
```

Значение FeatureFlag может быть типа `Bool`, `Int`, `Double` или `String`.

Пример получения значений Feature Flag:
```swift
import SigmaSDK

guard let client = Sigma.getClient() else { return }

// Callback версия
client.checkFlag(
    flagName: "my_first_flag",
    onSuccess: { (value: Bool?) in
        // Обработка значения Feature Flag
    },
    onError: { error in
        // Обработка ошибки
    }
)

// Async-await версия
do {
    let firstFlag: Bool? = try await client.checkFlag(flagName: "my_first_flag")
    // Обработка значения Feature Flag
} catch let error {
    // Обработка ошибки
}
```

Несмотря на то, что методы получения Feature Flag выбрасывают ошибки, даже при отсутствии ошибок значение флага может быть `nil`. Эта ситуация может возникнуть, например, в случае, если флаг привязан к эксперименту, в который пользователь не попал. Эта ситуация не ошибочная: ожидаемо, что для данного пользователя значение Feature Flag недоступно, поэтому SDK возвращает `nil`.

### Получение экспериментов

Для получения всех экспериментов, в которые попал пользователь, используются следующие методы `SigmaClient`:

```swift
func getUserExperiments(onSuccess: SigmaSuccessCallback<[SigmaExperiment]>?, onError: SigmaErrorCallback?)
func getUserExperiments() async throws -> [SigmaExperiment]
```

Для получения эксперимента по названию, используются следующие методы `SigmaClient`:

```swift
func getUserExperiment(name: String, onSuccess: SigmaSuccessCallback<SigmaExperiment?>?, onError: SigmaErrorCallback?)
func getUserExperiment(name: String) async throws -> SigmaExperiment?
```

Для получения названия эксперимента по названию Feature Flag, используются следующие методы `SigmaClient`:

```swift
func getExperimentNameByFeatureFlag(flagName: String, onSuccess: SigmaSuccessCallback<String?>?, onError: SigmaErrorCallback?)
func getExperimentNameByFeatureFlag(flagName: String) async throws -> String?
```

Все вышеописанные методы возвращают только те эксперименты, в которые попал пользователь.

Примеры получения экспериментов:

```swift
import SigmaSDK

guard let client = Sigma.getClient() else { return }
let flagName = "my_first_flag"

// Callback версии
client.getUserExperiments(
    onSuccess: { experiments in
        // Обработка всех экспериментов, в которые попал пользователь
    },
    onError: { error in
        // Обработка ошибки
    }
)

client.getUserExperiment(
    name: "my_first_experiment",
    onSuccess: { experiment in
        // Обработка эксперимента
    },
    onError: { error in
        // Обработка ошибки
    }
)

client.getExperimentNameByFeatureFlag(
    flagName: "my_first_flag",
    onSuccess: { experimentName in
        // Обработка имени эксперимента
    },
    onError: { error in
        // Обработка ошибки
    }
)

// Async-await версии
do {
    let allExperiments = try await client.getUserExperiments()
    // Обработка всех экспериментов, в которые попал пользователь
} catch let error {
    // Обработка ошибки
}

do {
    let userExperiment = try await client.getUserExperiment(name: "my_first_experiment")
    // Обработка эксперимента
} catch let error {
    // Обработка ошибки
}

do {
    let experimentName = try await client.getExperimentNameByFeatureFlag(name: "my_first_flag")
    // Обработка имени эксперимента
} catch let error {
    // Обработка ошибки
}
```

### Получение информации из эксперимента

После получения эксперимента, информация об эксперименте доступна из методов объекта `SigmaExperiment`:

```swift
func getParamValue<T: SigmaPropertyType>(name: String) -> T?
func getFeatureFlagValue<T: SigmaPropertyType>(flagName: String) throws -> T?
```

Значение FeatureFlag или параметра эксперимента может быть типа `Bool`, `Int`, `Double` или `String`.

## Список параметров, автоматически определяющихся на стороне SDK:

- `appVersion` - версия приложения пользователя.
- `deviceId` - уникальный идентификатор устройства.
- `os.version` - номер версии iOS на устройстве пользователя.
- `os.name` - название операционной системы пользователя (`iOS`/`macOS`/`watchOS`/`tvOS`).
- `time` - текущее время пользователя.
- `date` - текущая дата пользователя.
- `geo.country` - страна пользователя.
- `geo.state` - район пользователя.
- `geo.city` - город пользователя.
- `geo.ip` - IP-адрес пользователя.
