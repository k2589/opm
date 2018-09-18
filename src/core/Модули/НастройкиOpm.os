#Использовать json
#Использовать logos

Перем мНастройки;
Перем мПутьФайлаНастроек;
Перем Лог;
Перем КешИнтернетПрокси;

Функция ПолучитьНастройки() Экспорт
	Возврат мНастройки;
КонецФункции

Процедура УстановитьНастройкиПроксиСервера(Знач Сервер,
											Знач Порт = 0,
											Знач Пользователь = "",
											Знач Пароль = "",
											Знач ИспользоватьАутентификациюОС = Ложь) Экспорт
	
	НастройкиПрокси = Новый Структура();
	
	НастройкиПрокси.Вставить("Сервер", Сервер);
	НастройкиПрокси.Вставить("Порт", Порт);
	НастройкиПрокси.Вставить("Пользователь",Пользователь);
	НастройкиПрокси.Вставить("Пароль", Пароль);
	НастройкиПрокси.Вставить("ИспользоватьАутентификациюОС", ИспользоватьАутентификациюОС);
	
	мНастройки.НастройкиПрокси = НастройкиПрокси;

	мНастройки.ИспользоватьПрокси = ЗначениеЗаполнено(Сервер);
	мНастройки.ИспользоватьСистемныйПрокси = Ложь;

КонецПроцедуры

Функция ПолучитьИнтернетПрокси() Экспорт
	
	Если КешИнтернетПрокси = Неопределено 
		И мНастройки.ИспользоватьПрокси Тогда
		
		Если мНастройки.ИспользоватьСистемныйПрокси Тогда
			
			КешИнтернетПрокси = Новый ИнтернетПрокси(Истина);
			КешИнтернетПрокси.НеИспользоватьПроксиДляЛокальныхАдресов = Истина;

		Иначе
			
			НастройкиПрокси = мНастройки.НастройкиПрокси;
			
			КешИнтернетПрокси = Новый ИнтернетПрокси();
			
			КешИнтернетПрокси.Установить("http", НастройкиПрокси.Сервер, НастройкиПрокси.Порт, НастройкиПрокси.Пользователь, НастройкиПрокси.Пароль, НастройкиПрокси.ИспользоватьАутентификациюОС);
			
			КешИнтернетПрокси.НеИспользоватьПроксиДляЛокальныхАдресов = Истина;
	
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат КешИнтернетПрокси;

КонецФункции

Процедура УстановитьИспользованиеПрокси(Знач ЗначениеНастройки) Экспорт
	
	мНастройки.ИспользоватьПрокси = ЗначениеНастройки;
	
КонецПроцедуры

Процедура УстановитьСозданиеShСкриптЗапуска(Знач ЗначениеНастройки) Экспорт
	
	мНастройки.СоздаватьShСкриптЗапуска = ЗначениеНастройки;

КонецПроцедуры

Процедура УстановитьСистемныеНастройкиПроксиСервера(Знач ЗначениеНастройки) Экспорт
	
	мНастройки.ИспользоватьПрокси = ЗначениеНастройки;
	мНастройки.ИспользоватьСистемныйПрокси = ЗначениеНастройки;

КонецПроцедуры

Функция НастройкиСервераПакетов(Знач Имя, Знач Сервер, Знач ПутьНаСервере, Знач Порт, Знач Приоритет)
	
	Результат = Новый Структура;
	Результат.Вставить("Имя", Имя);
	Результат.Вставить("Сервер", Сервер);
	Результат.Вставить("ПутьНаСервере", ПутьНаСервере);
	Результат.Вставить("Порт", Порт);
	Результат.Вставить("Приоритет", Приоритет);
	
	Возврат Результат;

КонецФункции //

Процедура ДобавитьСерверПакетов(Знач Имя,
								Знач Сервер,
								Знач ПутьНаСервере = "",
								Знач Порт = 80,
								Знач Приоритет = Неопределено) Экспорт

	мНастройки.СервераПакетов.Добавить(НастройкиСервераПакетов(Имя, Сервер, ПутьНаСервере, Порт, Приоритет));
	Лог.Отладка("Добавлен дополнительный сервер <%1>, Адрес <%2>, ПутьНаСервере <%3>, Порт <%4>, Приоритет <%5>", Имя, Сервер, ПутьНаСервере, Порт, Приоритет);
				
КонецПроцедуры

Процедура СброситьНастройки() Экспорт
	
	Инициализация();

КонецПроцедуры

Процедура Инициализация()

	мНастройки = Новый Структура();
	мНастройки.Вставить("ИспользоватьПрокси", Ложь);
	мНастройки.Вставить("ИспользоватьСистемныйПрокси", Ложь);

	мНастройки.Вставить("НастройкиПрокси", Новый Структура("Сервер, Порт, Пользователь, Пароль, ИспользоватьАутентификациюОС", "","","","", Ложь));
	мНастройки.Вставить("СоздаватьShСкриптЗапуска", Ложь);
	мНастройки.Вставить("СервераПакетов", Новый Массив);

	// Сервера пакетов по умолчанию
	ДобавитьСерверПакетов("ОсновнойСерверПакетов", КонстантыOpm.СерверУдаленногоХранилища, КонстантыOpm.ПутьВХранилище, 80, 0);
	ДобавитьСерверПакетов("ЗапаснойСерверПакетов", КонстантыOpm.СерверЗапасногоХранилища, КонстантыOpm.ПутьВЗапасномХранилище, 80, 1);
	
КонецПроцедуры

Лог = Логирование.ПолучитьЛог("oscript.app.opm");

Инициализация();
