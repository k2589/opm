﻿#Использовать fluent
#Использовать fs
#Использовать logos
#Использовать tempfiles

Перем Лог;
Перем мВременныйКаталогУстановки;
Перем мЗависимостиВРаботе;
Перем ЭтоWindows;
Перем мРежимУстановкиПакетов;

Перем мЦелевойКаталог;
Перем Метаданные;

Процедура УстановитьПакетИзАрхива(Знач ФайлАрхива) Экспорт

	Лог.Отладка("Устанавливаю пакет из архива: " + ФайлАрхива);
	Если мЗависимостиВРаботе = Неопределено Тогда
		мЗависимостиВРаботе = Новый Соответствие;
	КонецЕсли;

	мВременныйКаталогУстановки = ВременныеФайлы.СоздатьКаталог();
	Лог.Отладка("Временный каталог установки: " + мВременныйКаталогУстановки);

	ПутьУстановки = "";
	Попытка

		Лог.Отладка("Открываем архив пакета");
		ЧтениеПакета = Новый ЧтениеZipФайла;
		ЧтениеПакета.Открыть(ФайлАрхива);

		ФайлСодержимого = ИзвлечьОбязательныйФайл(ЧтениеПакета, КонстантыOpm.ИмяФайлаСодержимогоПакета);
		ФайлМетаданных  = ИзвлечьОбязательныйФайл(ЧтениеПакета, КонстантыOpm.ИмяФайлаМетаданныхПакета);

		Метаданные = ПрочитатьМетаданныеПакета(ФайлМетаданных);
		ИмяПакета = Метаданные.Свойства().Имя;

		ОбъектКаталогУстановки = НайтиСоздатьКаталогУстановки(ИмяПакета);
		ПутьУстановки = ОбъектКаталогУстановки.ПолноеИмя;

		Лог.Информация("Устанавливаю пакет " +  ИмяПакета);
		ПроверитьВерсиюСреды(Метаданные);
		Если мЗависимостиВРаботе[ИмяПакета] = "ВРаботе" Тогда
			ВызватьИсключение "Циклическая зависимость по пакету " + ИмяПакета;
		КонецЕсли;

		мЗависимостиВРаботе.Вставить(ИмяПакета, "ВРаботе");

		СтандартнаяОбработка = Истина;
		УстановитьФайлыПакета(ОбъектКаталогУстановки, ФайлСодержимого, СтандартнаяОбработка);
		Если СтандартнаяОбработка Тогда
			СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(ПутьУстановки, Метаданные);
			РаботаСПакетами.СоздатьКонфигурационныеФайлыОСкрипт(ПутьУстановки, Метаданные, мРежимУстановкиПакетов);
		КонецЕсли;
		СохранитьФайлМетаданныхПакета(ПутьУстановки, ФайлМетаданных);

		ЧтениеПакета.Закрыть();

		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);

		мЗависимостиВРаботе.Вставить(ИмяПакета, "Установлен");

	Исключение
		Лог.Предупреждение("Обрабатываю возникшую ошибку...");
		Если ЗначениеЗаполнено(ПутьУстановки) Тогда
			УдалитьКаталогУстановкиПриОшибке(ПутьУстановки);
		КонецЕсли;
		ЧтениеПакета.Закрыть();
		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);
		ВызватьИсключение;
	КонецПопытки;

	Лог.Информация("Установка завершена");

КонецПроцедуры

Процедура УстановитьКешПакетов(КэшПакетовВУстановке) Экспорт
	мЗависимостиВРаботе = КэшПакетовВУстановке;
КонецПроцедуры

Функция ПолучитьМанифестПакета() Экспорт
	Возврат Метаданные;
КонецФункции

Процедура УстановитьРежимУстановкиПакета(Знач ЗначениеРежимУстановкиПакетов) Экспорт
	мРежимУстановкиПакетов = ЗначениеРежимУстановкиПакетов;
КонецПроцедуры

Процедура ПроверитьВерсиюСреды(Манифест)

	Свойства = Манифест.Свойства();
	Если НЕ Свойства.Свойство("ВерсияСреды") Тогда
		Возврат;
	КонецЕсли;

	ИмяПакета = Свойства.Имя;
	ТребуемаяВерсияСреды = Свойства.ВерсияСреды;
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ВерсияСреды = СистемнаяИнформация.Версия;
	Лог.Отладка("ПроверитьВерсиюСреды: Перед вызовом СравнитьВерсии(ЭтаВерсия = <%1>, БольшеЧемВерсия = <%2>)", ТребуемаяВерсияСреды, ВерсияСреды);
	Если РаботаСВерсиями.СравнитьВерсии(ТребуемаяВерсияСреды, ВерсияСреды) > 0 Тогда
			ТекстСообщения = СтрШаблон(
			"Ошибка установки пакета <%1>: Обнаружена устаревшая версия движка OneScript.
			|Требуемая версия: %2
			|Текущая версия: %3
			|Обновите OneScript перед установкой пакета",
			ИмяПакета,
			ТребуемаяВерсияСреды,
			ВерсияСреды
		);

		ВызватьИсключение ТекстСообщения;
	КонецЕсли;

КонецПроцедуры

Процедура УстановитьЦелевойКаталог(Знач ЦелевойКаталогУстановки) Экспорт
	Лог.Отладка("Каталог установки пакета '%1'", ЦелевойКаталогУстановки);
	ФС.ОбеспечитьКаталог(ЦелевойКаталогУстановки);
	мЦелевойКаталог = ЦелевойКаталогУстановки;
КонецПроцедуры

Функция НайтиСоздатьКаталогУстановки(Знач ИдентификаторПакета)

	ОбъектКаталогУстановки = Новый Файл(ОбъединитьПути(мЦелевойКаталог, ИдентификаторПакета));
	ПутьУстановки = ОбъектКаталогУстановки.ПолноеИмя;
	Лог.Отладка("Путь установки пакета: " + ПутьУстановки);

	Если Не ОбъектКаталогУстановки.Существует() Тогда
		СоздатьКаталог(ПутьУстановки);
	ИначеЕсли ОбъектКаталогУстановки.ЭтоФайл() Тогда
		ВызватьИсключение "Не удалось создать каталог " + ПутьУстановки;
	КонецЕсли;

	Возврат ОбъектКаталогУстановки;

КонецФункции

Процедура УстановитьФайлыПакета(Знач ОбъектКаталогУстановки, Знач ФайлСодержимого, СтандартнаяОбработка)

	ЧтениеСодержимого = Новый ЧтениеZipФайла(ФайлСодержимого);
	КаталогУстановки = ОбъектКаталогУстановки.ПолноеИмя;

	Попытка

		Лог.Отладка("Устанавливаю файлы пакета из архива");
		УдалитьУстаревшиеФайлы(ОбъектКаталогУстановки);

		ИзвлечьФайл(ЧтениеСодержимого, КонстантыOpm.ИмяФайлаСпецификацииПакета, КаталогУстановки);

		Попытка
			ОбработчикСобытий = ПолучитьОбработчикСобытий(КаталогУстановки);
		Исключение
			ОписаниеОшибки = ОписаниеОшибки();
			Лог.Предупреждение("Не удалось обработать описание частичного распакованного пакета
			|Выполняю полную распаковку пакета
			|
			|%1", ОписаниеОшибки);

			ОбработчикСобытий = Неопределено;
		КонецПопытки;
		ПолученОбработчикСобытий = ОбработчикСобытий <> Неопределено;

		Если ПолученОбработчикСобытий Тогда
			ВызватьСобытиеПередУстановкой(ОбработчикСобытий, КаталогУстановки, ЧтениеСодержимого);
		КонецЕсли;

		ЧтениеСодержимого.ИзвлечьВсе(КаталогУстановки);

		Если Не ПолученОбработчикСобытий Тогда
			ОбработчикСобытий = ПолучитьОбработчикСобытий(КаталогУстановки);
		КонецЕсли;

		ВызватьСобытиеПриУстановке(ОбработчикСобытий, КаталогУстановки, СтандартнаяОбработка);

	Исключение
		ЧтениеСодержимого.Закрыть();
		ВызватьИсключение;
	КонецПопытки;

	ЧтениеСодержимого.Закрыть();

КонецПроцедуры

Процедура УдалитьУстаревшиеФайлы(Знач ОбъектКаталогУстановки)
	Лог.Отладка("Удаляю устаревшие файлы");
	ПутьУстановки = ОбъектКаталогУстановки.ПолноеИмя;
	УдалитьФайлыВКаталоге(ПутьУстановки, "*.os", Истина);
	УдалитьФайлыВКаталоге(ПутьУстановки, "*.dll", Истина);
	УдалитьФайлыВКаталоге(ПутьУстановки, "packagedef", Ложь);
КонецПроцедуры

Процедура УдалитьФайлыВКаталоге(Знач ПутьКаталога, Знач МаскаФайлов, Знач ИскатьВПодкаталогах = Истина)
	ФайлыДляУдаления = НайтиФайлы(ПутьКаталога, МаскаФайлов, ИскатьВПодкаталогах);
	Для Каждого Файл из ФайлыДляУдаления Цикл
		УдалитьФайлы(Файл.ПолноеИмя);
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьОбработчикСобытий(Знач ПутьУстановки)
	ОбработчикСобытий = Неопределено;
	ИмяФайлаСпецификацииПакета = КонстантыOpm.ИмяФайлаСпецификацииПакета;
	ПутьКФайлуСпецификации = ОбъединитьПути(ПутьУстановки, ИмяФайлаСпецификацииПакета);
	Если ФС.ФайлСуществует(ПутьКФайлуСпецификации) Тогда
		Лог.Отладка("Найден файл спецификации пакета");
		Лог.Отладка("Компиляция файла спецификации пакета");

		ОписаниеПакета = Новый ОписаниеПакета();
		ВнешнийКонтекст = Новый Структура("Описание", ОписаниеПакета);
		ОбработчикСобытий = ЗагрузитьСценарий(ПутьКФайлуСпецификации, ВнешнийКонтекст);
	КонецЕсли;

	Возврат ОбработчикСобытий;
КонецФункции

Процедура ВызватьСобытиеПередУстановкой(Знач ОбработчикСобытий, Знач Каталог, Знач ЧтениеZipФайла)

	Если ОбработчикСобытий = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Рефлектор = Новый Рефлектор;
	Если Рефлектор.МетодСуществует(ОбработчикСобытий, "ПередУстановкой") Тогда
		Лог.Отладка("Вызываю событие ПередУстановкой");
		ОбработчикСобытий.ПередУстановкой(Каталог, ЧтениеZipФайла);
	КонецЕсли;

КонецПроцедуры

Процедура ВызватьСобытиеПриУстановке(Знач ОбработчикСобытий, Знач Каталог, СтандартнаяОбработка)

	Если ОбработчикСобытий = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Рефлектор = Новый Рефлектор;
	Если Рефлектор.МетодСуществует(ОбработчикСобытий, "ПриУстановке") Тогда
		Лог.Отладка("Вызываю событие ПриУстановке");
		ОбработчикСобытий.ПриУстановке(Каталог, СтандартнаяОбработка);
	КонецЕсли;

КонецПроцедуры

Процедура СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(Знач КаталогУстановки, Знач ОписаниеПакета)

	ИмяПакета = ОписаниеПакета.Свойства().Имя;

	Для Каждого ФайлПриложения Из ОписаниеПакета.ИсполняемыеФайлы() Цикл

		ИмяСкриптаЗапуска = ?(ПустаяСтрока(ФайлПриложения.ИмяПриложения), ИмяПакета, ФайлПриложения.ИмяПриложения);
		Лог.Информация("Регистрация приложения: " + ИмяСкриптаЗапуска);

		ОбъектФайл = Новый Файл(ОбъединитьПути(КаталогУстановки, ФайлПриложения.Путь));

		Если Не ОбъектФайл.Существует() Тогда
			Лог.Ошибка("Файл приложения " + ОбъектФайл.ПолноеИмя + " не существует");
			ВызватьИсключение "Некорректные данные в метаданных пакета";
		КонецЕсли;

		Если мРежимУстановкиПакетов = РежимУстановкиПакетов.Локально Тогда
			КаталогУстановкиСкриптовЗапускаПриложений = ОбъединитьПути(КонстантыOpm.ЛокальныйКаталогУстановкиПакетов, "bin");
			ФС.ОбеспечитьКаталог(КаталогУстановкиСкриптовЗапускаПриложений);
			КаталогУстановкиСкриптовЗапускаПриложений = Новый Файл(КаталогУстановкиСкриптовЗапускаПриложений).ПолноеИмя;
		ИначеЕсли мРежимУстановкиПакетов = РежимУстановкиПакетов.Глобально Тогда
			КаталогУстановкиСкриптовЗапускаПриложений = ?(ЭтоWindows, КаталогПрограммы(), ВыбратьКаталогДляLinuxИлиMacOs());
			Если НЕ ПустаяСтрока(ПолучитьПеременнуюСреды("OSCRIPTBIN")) Тогда
				КаталогУстановкиСкриптовЗапускаПриложений = ПолучитьПеременнуюСреды("OSCRIPTBIN");
			КонецЕсли;
		Иначе
			ВызватьИсключение "Неизвестный режим установки пакетов <" + мРежимУстановкиПакетов + ">";
		КонецЕсли;

		СоздатьСкриптЗапуска(ИмяСкриптаЗапуска, ОбъектФайл.ПолноеИмя, КаталогУстановкиСкриптовЗапускаПриложений);

	КонецЦикла;

КонецПроцедуры

Функция ВыбратьКаталогДляLinuxИлиMacOs()

	ТекстовыйДокумент = Новый ТекстовыйДокумент();
	Попытка
		ТекстовыйДокумент.Записать("/usr/bin/anus.txt");
		УдалитьФайлы("/usr/bin/anus.txt");
		Возврат "/usr/bin";
	Исключение
		Возврат "/usr/local/bin";
	КонецПопытки;

КонецФункции

Процедура СоздатьСкриптЗапуска(Знач ИмяСкриптаЗапуска, Знач ПутьФайлаПриложения, Знач Каталог) Экспорт

	Если ЭтоWindows Тогда
		ФайлЗапуска = Новый ЗаписьТекста(ОбъединитьПути(Каталог, ИмяСкриптаЗапуска + ".bat"), "cp866");
		ФайлЗапуска.ЗаписатьСтроку("@oscript.exe """ + ПутьФайлаПриложения + """ %*");
		ФайлЗапуска.ЗаписатьСтроку("@exit /b %ERRORLEVEL%");
		ФайлЗапуска.Закрыть();
	КонецЕсли;

	Если (ЭтоWindows И НастройкиOpm.ПолучитьНастройки().СоздаватьShСкриптЗапуска) ИЛИ НЕ ЭтоWindows Тогда
		ПолныйПутьКСкриптуЗапуска = ОбъединитьПути(Каталог, ИмяСкриптаЗапуска);
		ФайлЗапуска = Новый ЗаписьТекста(ПолныйПутьКСкриптуЗапуска, КодировкаТекста.UTF8NoBOM,,, Символы.ПС);
		ФайлЗапуска.ЗаписатьСтроку("#!/bin/bash");
		СтрокаЗапуска = "oscript";
		Если ЭтоWindows Тогда
			СтрокаЗапуска = СтрокаЗапуска + " -encoding=utf-8";
		КонецЕсли;
		СтрокаЗапуска = СтрокаЗапуска + " """ + ПутьФайлаПриложения + """ ""$@""";
		ФайлЗапуска.ЗаписатьСтроку(СтрокаЗапуска);
		ФайлЗапуска.Закрыть();

		Если НЕ ЭтоWindows Тогда
			ЗапуститьПриложение("chmod +x """ + ПолныйПутьКСкриптуЗапуска + """");
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Функция ПрочитатьМетаданныеПакета(Знач ФайлМетаданных)

	Перем Метаданные;
	Лог.Отладка("Чтение метаданных пакета");
	Попытка
		Чтение = Новый ЧтениеXML;
		Чтение.ОткрытьФайл(ФайлМетаданных);
		Лог.Отладка("XML загружен");
		Сериализатор = Новый СериализацияМетаданныхПакета;
		Метаданные = Сериализатор.ПрочитатьXML(Чтение);

		Чтение.Закрыть();
	Исключение
		Чтение.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	Лог.Отладка("Метаданные прочитаны");

	Возврат Метаданные;

КонецФункции

Процедура СохранитьФайлМетаданныхПакета(Знач ПутьУстановки, Знач ПутьКФайлуМетаданных)

	ПутьСохранения = ОбъединитьПути(ПутьУстановки, КонстантыOpm.ИмяФайлаМетаданныхПакета);
	ДанныеФайла = Новый ДвоичныеДанные(ПутьКФайлуМетаданных);
	ДанныеФайла.Записать(ПутьСохранения);

КонецПроцедуры

Процедура УдалитьКаталогУстановкиПриОшибке(Знач Каталог)
	Лог.Отладка("Удаляю каталог " + Каталог);
	Попытка
		УдалитьФайлы(Каталог);
	Исключение
		Лог.Отладка("Не удалось удалить каталог " + Каталог + "
		|	- " + ОписаниеОшибки());
	КонецПопытки
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////
//

Функция ИзвлечьОбязательныйФайл(Знач Чтение, Знач ИмяФайла)

	ПутьФайла = ИзвлечьФайл(Чтение, ИмяФайла, мВременныйКаталогУстановки);
	Если ПутьФайла = "" Тогда
		ВызватьИсключение "Неверная структура пакета. Не найден файл " + ИмяФайла;
	КонецЕсли;

	Возврат ПутьФайла;

КонецФункции

Функция ИзвлечьФайл(Знач Чтение, Знач ИмяФайла, Знач КаталогКудаИзвлечь)
	Лог.Отладка("Извлечение: %1", ИмяФайла);
	Лог.Отладка("Извлечение: КаталогКудаИзвлечь %1", КаталогКудаИзвлечь);

	Элемент = НайтиЭлементАрхива(Чтение, ИмяФайла);
	Если Элемент = Неопределено Тогда
		Лог.Отладка("Не удалось извлечь файл %1", ИмяФайла);
		Возврат "";
	КонецЕсли;

	Чтение.Извлечь(Элемент, КаталогКудаИзвлечь);

	Возврат ОбъединитьПути(мВременныйКаталогУстановки, ИмяФайла);

КонецФункции

Функция НайтиЭлементАрхива(Знач Чтение, Знач ПолноеИмя)
	Лог.Отладка("НайтиЭлементАрхива: ищем в архиве файл %1", ПолноеИмя);
	Файл = Новый Файл(ПолноеИмя);
	Если Лев(Файл.Путь, 2) = ".\" Или Лев(Файл.Путь, 2) = "./" Тогда
		ПолноеИмя = Файл.Имя;
	КонецЕсли;
	Для Каждого Элемент Из Чтение.Элементы Цикл

		Если НРег(Элемент.ПолноеИмя) = НРег(ПолноеИмя) Тогда
			Лог.Отладка("НайтиЭлементАрхива: нашли Элемент.ПолноеИмя %1", Элемент.ПолноеИмя);

			Возврат Элемент;
		КонецЕсли;
	КонецЦикла;
	Лог.Отладка("НайтиЭлементАрхива: не нашли элемент");
	Возврат Неопределено;
КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.app.opm");
СИ = Новый СистемнаяИнформация();
ЭтоWindows = Найти(СИ.ВерсияОС, "Windows") > 0;
мРежимУстановкиПакетов = РежимУстановкиПакетов.Глобально;

ПроверкаДоступностиUsrBin();