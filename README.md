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
- `func setDeviceId(_ id: String) -> SigmaUser.Builder` - переопределение Device ID, определенного SDK.
- `func setEmail(_ email: String) -> SigmaUser.Builder` - назначение параметра пользователя с названием `email`.
- `func setAppVersion(_ version: String) -> SigmaUser.Builder` - переопределение версии приложения, определенной SDK.
- `func setOsName(_ name: String) -> SigmaUser.Builder` - переопределение названия операционной системы, определенной SDK.
- `func setOsVersion(_ version: String) -> SigmaUser.Builder` - переопределение версии операционной системы, определенной SDK.
- `func setGeoCode(_ code: String) -> SigmaUser.Builder` - переопределение гео кода, определенного SDK.
- `func setGeoCountry(_ country: String) -> SigmaUser.Builder` - переопределение страны, определенной SDK.
- `func setGeoState(_ state: String) -> SigmaUser.Builder` - переопределение региона, определенного SDK.
- `func setGeoCity(_ code: String) -> SigmaUser.Builder` - переопределение города, определенного SDK.
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
- `apiURL: String` - URL для Sigma API. Необязательный параметр. По умолчанию равен "https://api.expf.ru/api/v1/".
- `cacheTTL: UInt` - частота (в секундах) запрашивания конфигурации из сети. Необязательный параметр. По умолчанию равен 10 секундам.
- `retryCount: UInt` -  количество повторных попыток запрашивания конфигурации при неудачном запросе. Необязательный параметр. По умолчанию равен 3.
- `tag: String` - тег клиента Sigma. Необязательный параметр. По умолчанию равен "default". Необходим для создания нескольких экземпляров SigmaClient.

Для получения клиента `SigmaClient` используется метод `Sigma.getClient(tag: String)`.
Для завершения работы над клиентом используется метод `Sigma.removeClient(tag: String)`

При инициализации уже инициализированного клиента (с уже существующим тегом) будет выброшена ошибка `SigmaError.initializationOfExistingClient`.

### Обновление информации о пользователе

Доступ к `SigmaClient` позволяет обновить параметры объекта `SigmaUser`, принадлежащего клиенту. `SigmaClient` обладает следующими методами:

- `func setUserProperties(builder: (SigmaUser.Builder) -> SigmaUser.Builder)` - переназначение всех свойств пользователя. Ранее объявленные свойства пользователя будут удалены.
- `func editUserProperties(builder: (SigmaUser.Builder) -> SigmaUser.Builder)` - обновление свойств пользователя. Ранее объявленные свойства не будут удалены, но их значения могут быть перезаписаны с помощью блока `builder`.
- `func clearUserProperties()` - удаление всех свойств пользователя. Эквивалентно созданию нового пользователя без параметров.

### Получение значений Feature Flag

Для получения значений Feature Flag используются следующие методы `SigmaClient`:

```swift
func checkFlag<T: SigmaPropertyType>(flagName: String, onSuccess: SigmaSuccessCallback<T?>?, onError: SigmaErrorCallback?)
func checkFlag<T: SigmaPropertyType>(flagName: String) async throws -> T?
```

Значение FeatureFlag может быть типа `Bool`, `Int`, `Double`, `String` или `[String: Any]`.

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

Для получения полного списка Feature Flag, которые есть у пользователя, используются следующие методы `SigmaClient`:

```swift
func getUserFeatureFlagsDetails(onSuccess: SigmaSuccessCallback<[String: SigmaPropertyType]>?, onError: SigmaErrorCallback?)
func getUserFeatureFlagsDetails() async throws -> [String: SigmaPropertyType]
```

Методы возвращают словарь, где ключом является название Feature Flag, а значением - значение Feature Flag. Значение FeatureFlag может быть типа `Bool`, `Int`, `Double`, `String` или `[String: Any]`.

Пример получения полного списка Feature Flag:
```swift
import SigmaSDK

guard let client = Sigma.getClient() else { return }

// Callback версия
client.getUserFeatureFlagsDetails(
    onSuccess: { dictionary in
        if let dictionaryFlag = dictionary["my_feature_flag"] as? [String: Any] {
            // Обработка значения Feature Flag типа [String: Any]
        } else {
            // Обработка значения Feature Flag типа Bool, Int, Double или String
        }
    },
    onError: { error in
        // Обработка ошибки
    }
)

// Async-await версия
do {
    let dictionary = try await client.getUserFeatureFlagsDetails()
    if let dictionaryFlag = dictionary["my_feature_flag"] as? [String: Any] {
        // Обработка значения Feature Flag типа [String: Any]
    } else {
        // Обработка значения Feature Flag типа Bool, Int, Double или String
    }
} catch let error {
    // Обработка ошибки
}
```

### Получение экспериментов

Для получения всех экспериментов, в которые попал пользователь, используются следующие методы `SigmaClient`:

```swift
func getAllUserExperiments(onSuccess: SigmaSuccessCallback<[SigmaExperiment]>?, onError: SigmaErrorCallback?)
func getAllUserExperiments() async throws -> [SigmaExperiment]
```

Для получения эксперимента по названию, используются следующие методы `SigmaClient`:

```swift
func getExperiment(name: String, onSuccess: SigmaSuccessCallback<SigmaExperiment?>?, onError: SigmaErrorCallback?)
func getExperiment(name: String) async throws -> SigmaExperiment?
```

Все вышеописанные методы возвращают только те эксперименты, в которые попал пользователь.

Примеры получения экспериментов:

```swift
import SigmaSDK

guard let client = Sigma.getClient() else { return }
let flagName = "my_first_flag"

// Callback версии
client.getAllUserExperiments(
    onSuccess: { experiments in
        // Обработка всех экспериментов, в которые попал пользователь
    },
    onError: { error in
        // Обработка ошибки
    }
)

client.getExperiment(
    name: "my_first_experiment",
    onSuccess: { experiment in
        // Обработка эксперимента
    },
    onError: { error in
        // Обработка ошибки
    }
)

// Async-await версии
do {
    let allExperiments = try await client.getAllUserExperiments()
    // Обработка всех экспериментов, в которые попал пользователь
} catch let error {
    // Обработка ошибки
}

do {
    let userExperiment = try await client.getExperiment(name: "my_first_experiment")
    // Обработка эксперимента
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

Значение FeatureFlag или параметра эксперимента может быть типа `Bool`, `Int`, `Double`, `String` или `[String: Any]`.

### Принудительное добавление пользователя в эксперимент (debug-only)

Для того, чтобы принудительно добавить пользователя в эксперимент, используются следующие методы `SigmaClient`:

```swift
func includeForce(experimentName: String, groupIndex: Int?, onSuccess: SigmaSuccessCallback<Void>?, onError: SigmaErrorCallback?)
func includeForce(experimentName: String, groupIndex: Int?) async throws
func includeForce(experimentName: String, onSuccess: SigmaSuccessCallback<Void>?, onError: SigmaErrorCallback?)
func includeForce(experimentName: String) async throws
func excludeForce(experimentName: String, onSuccess: SigmaSuccessCallback<Void>?, onError: SigmaErrorCallback?)
func excludeForce(experimentName: String) async throws
func excludeForceAll(onSuccess: SigmaSuccessCallback<Void>?, onError: SigmaErrorCallback?)
func excludeForceAll() async throws
```

Методы `includeForce(...)` принудительно добавят пользователя в forced user list эксперимента, если не передан `groupIndex`, или в forced user list группы эксперимента, если `groupIndex` передан (при наличии соответствующей группы в эксперименте). Результаты работы данных методов кэшируются и будут влиять на последующие запуски приложения (только на текущем устройстве). Для того, чтобы обратить действие данных методов, используются методы `excludeForce(...)` (для конкретного эксперимента) или `excludeForceAll()` (для всех экспериментов). Данные методы не предназначены для production, а должны быть использованы при тестировании через debug-меню или его аналоги. Данные методы имеют приоритет над forced user list, получаемом с сервера.

Примеры принудительного добавления пользователя в эксперимент:

```swift
import SigmaSDK

guard let client = Sigma.getClient() else { return }
let experimentName = "experiment_name"

// Callback версии
client.includeForce(
    experimentName: experimentName,
    onSuccess: {
        // Пользователь добавлен в принудительный список
    },
    onError: { error in
        // Произошла ошибка
    }
)

client.excludeForce(
    experimentName: experimentName,
    onSuccess: { experiment in
        // Пользователь исключен из принудительного списка
    },
    onError: { error in
        // Произошла ошибка
    }
)

// Async-await версии
do {
    try await client.includeForce(experimentName: experimentName)
    // Пользователь добавлен в принудительный список
} catch let error {
    // Произошла ошибка
}

do {
    try await client.excludeForce(experimentName: experimentName)
    // Пользователь исключен из принудительного списка
} catch let error {
    // Произошла ошибка
}
```

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

## Changelog

### 1.4.3
- Исправлена ошибка, когда значение Feature Flag бралось из эксперимента, в который пользователь не попал по ЦА.

### 1.4.2
- Исправлена ошибка, когда Feature Flag с единственным правилом по умолчанию мог не возвращаться клиенту из-за проваленной проверки на пустые условия данного правила.

### 1.4.1
- Улучшен метод `SigmaClient.includeForce`. Теперь можно вызывать несколько `SigmaClient.includeForce` последовательно, последний вызов перетирает предыдущие. Также, вызов данного метода теперь приоритетнее forced user list, получаемого с сервера - даже если пользователь уже в принудительном списке эксперимента, метод `SigmaClient.includeForce` может переместить пользователя в принудительный список группы, и обратно.

### 1.4.0
- Добавлены методы `SigmaClient.includeForce`, `SigmaClient.excludeForce`, `SigmaClient.excludeForceAll` для принудительного включения пользвователя в эксперимент (debug-only)

### 1.3.3
- Добавлен метод `SigmaClient.getUserFeatureFlagsDetails` для получения всех Feature Flag пользователя.
- Добавлена поддержка списка платформ вместо одной платформы в экспериментах.

### 1.3.2
- Усовершенствован механизм проверки актуальности свойств `SigmaUser`. Каждое свойство пользователя считается актуальным только в течение 24 часов после его назначения / изменения.

### 1.3.1
- Добавлена возможность кастомизации URL для Sigma API с помощью метода `Sigma.initializeClient`: добавлен новый параметр `apiURL`.

### 1.3.0
- Добавлены методы `SigmaClient.setUserProperties`, `SigmaClient.editUserProperties`, `SigmaClient.clearUserProperties`, позволяющие редактировать информацию о `SigmaUser`.

### 1.2.5
- Улучшена логика работы принудительного списка пользователей эксперимента: теперь он приоритетнее целевой аудитории в эксперименте.

### 1.2.4
- Улучшена логика подсчета попадания пользователя в эксперимент.

### 1.2.3
- Добавлена поддержка типа [String: Any] как значения Feature Flag или параметра эксперимента.

### 1.2.2
- Добавлена поддержка новых операторов "starts with", "not starts with", "ends with", "not ends with", "contains", "not contains".

### 1.2.1
- Добавлена поддержка фильтрации экспериментов и Feature Flag по платформе.
- Улучшено декодирование файла конфигурации, при котором поврежденные объекты не будут повреждать весь файл конфигурации.

### 1.2.0
- Метод `SigmaExperiment.getFeatureFlagValue` переименован в `SigmaExperiment.getFeatureValue`.
- Свойства `SigmaExperiment.name` и `SigmaExperiment.userGroupName` помечены устаревшими и будут удалены в следующих релизах.
- Добавлено свойство `SigmaExperiment.groupIndex`, возвращающее индекс группы эксперимента, в которую попал пользователь.

### 1.1.0
- Удален метод `getExperimentNameByFeatureFlag`.
- Метод `getUserExperiments` переименован в `getAllUserExperiments`.
- Метод `getUserExperiment` переименован в `getExperiment`. 
- Исправлена логика расчета значения Feature Flag, если он есть в эксперименте, но пользователь в него не попал, при которой возвращался nil, вместо fallback на Feature Flag вне эксперимента.
- Добавлены методы `SigmaUser.Builder`: `setAppVersion`, `setOsName`, `setOsVersion`, `setGeoCode`, `setGeoCountry`, `setGeoState`, `setGeoCity`.
- Исправлена ошибка, при которой параметры геолокации устанавливались на клиенте как `code`, `country`, `state`, `city` вместо `geo.code`, `geo.country`, `geo.state`, `geo.city`.


### 1.0.1
- Добавлена поддержка iOS 11+.
- Исправлена ошибка, при которой пустой набор правил с оператором OR считался всегда успешным.

### 1.0.0
- Начальная версия SDK.
