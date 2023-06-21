#!/bin/bash
# Установка переменных
DB_NAME="sitemanager"
DUMP_DIR="/tmp/sitemanager"
TABLES=$(mysql -N -s -e "SHOW TABLES FROM ${DB_NAME}")
# Список таблиц, которые нужно пропустить
SKIPPED_TABLES=("b_bitrixcloud_option" "b_blog")

# Создание директории для экспорта
mkdir -p ${DUMP_DIR}

# Цикл для экспорта таблиц
for table in ${TABLES}; do
  # Проверка, нужно ли экспортировать таблицу
  if [[ " ${SKIPPED_TABLES[*]} " == *" ${table} "* ]]; then
    echo "Skipping table ${table}"
    continue
  fi

  # Экспорт таблицы
  echo "Exporting table ${table}"
  # Применять для тестирования успешного дамба начала таблицы, есть таблицы которые можно сдамбить, но не все строки
  #mysqldump ${DB_NAME} ${table} --where="1 limit 1" > ${DUMP_DIR}/${table}.sql

  mysqldump ${DB_NAME} ${table} > ${DUMP_DIR}/${table}.sql
    
  # Проверка на ошибку
  if [ $? -ne 0 ]; then
    echo "Error exporting table ${table}. Exiting."
  	systemctl start mysql
	  while ! systemctl status mysqld &>/dev/null; do
  		echo "MySQL server is not available. Waiting..."
		  systemctl start mysql
  		sleep 1
	  done
	  echo "MySQL server is available."
  else
	  echo ${table} >> limit-ok.log
  fi
done
echo "All tables have been successfully exported."
