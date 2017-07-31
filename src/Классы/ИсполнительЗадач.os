#Использовать logos

Перем Лог;

Процедура ВыполнитьЗадачу(Знач ИмяЗадачи, Знач ПараметрыЗадачи) Экспорт
	
	Если ПараметрыЗадачи = Неопределено Тогда
		ПараметрыЗадачи = Новый Массив;
	КонецЕсли;

	ПутьККаталогуЗадач = "";
	
	Попытка
		ОписаниеПакета = РаботаСОписаниемПакета.ПрочитатьОписаниеПакета();
		Свойства = ОписаниеПакета.Свойства();
		Если Свойства.Свойство("Задачи") Тогда
			ПутьККаталогуЗадач = Свойства.Задачи;
		КонецЕсли;
	Исключение
	КонецПопытки;

	Если НЕ ЗначениеЗаполнено(ПутьККаталогуЗадач) Тогда
		ПутьККаталогуЗадач = ОбъединитьПути(ТекущийКаталог(), "tasks");
	КонецЕсли;

	КаталогЗадач = Новый Файл(ПутьККаталогуЗадач);
	Если НЕ КаталогЗадач.Существует() Тогда
		ТекстСообщения = СтрШаблон("Не найден каталог задач: %1", КаталогЗадач.ПолноеИмя);
		Лог.Ошибка(ТекстСообщения);
		Возврат;
	КонецЕсли;

	ПутьКЗадаче = ОбъединитьПути(ПутьККаталогуЗадач, ИмяЗадачи + ".os");
	
	ФайлЗадачи = Новый Файл(ПутьКЗадаче);
	Если НЕ ФайлЗадачи.Существует() Тогда
		ТекстСообщения = СтрШаблон("Файл задачи не существует: %1", ФайлЗадачи.ПолноеИмя);
		Лог.Ошибка(ТекстСообщения);
		Возврат;
	КонецЕсли;

	ПараметрыСценария = Новый Структура("АргументыКоманднойСтроки", ПараметрыЗадачи);
	ЗагрузитьСценарий(ПутьКЗадаче, ПараметрыСценария);

КонецПроцедуры

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог("oscript.app.opm");

КонецПроцедуры

Инициализация();
