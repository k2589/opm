///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ОписаниеКоманды(Знач КомандаПриложения) Экспорт
	
	КомандаПриложения.Аргумент("TASK", "", "Имя выполняемой задачи.");
	КомандаПриложения.Аргумент("ARGS", "", "Коллекция параметров, передаваемых задаче")
						.ТМассивСтрок()
						.Обязательный(Ложь);

КонецПроцедуры

Процедура ВыполнитьКоманду(Знач КомандаПриложения) Экспорт

	ИмяЗадачи = КомандаПриложения.ЗначениеАргумента("TASK");
	ПараметрыЗадачи = КомандаПриложения.ЗначениеАргумента("ARGS");

	ИсполнительЗадач = Новый ИсполнительЗадач();
	ИсполнительЗадач.ВыполнитьЗадачу(ИмяЗадачи, ПараметрыЗадачи);
	
КонецПроцедуры