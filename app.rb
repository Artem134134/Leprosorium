#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

# before вызвается каждый раз при перезагрузке любой странице
before do
	# инициализация БД
	init_db
end

# configure вызывается каждый раз при конфигурации приложения:
# когда изменился код программы и перезапустилась таблица
configure do
	# инициализация БД
	init_db 

	# Создает таблицу если таблица не существует
	@db.execute'CREATE TABLE IF NOT EXISTS Posts (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content      TEXT
)'

end

get '/' do
	# выбираем список постов из БД
	results = @db.execute 'select * from Posts order by id desc'
	erb :index 		
end

# обработчик get-запроса /new
#(браузер получает страницу с сервера)
get '/new' do
	erb :new
end

# обработчик из post-запроса /new
#(браузер отправляет данные на сервер)
post '/new' do
	# получаем переменную из post-запроса
	@content = params[:content]

	if content.size <= 0
		@error = 'Type post text'	
		return erb :new
	end

# сохранение данных в БД
	@db.execute 'insert into Posts (content, created_date) values (?,datetime())', [content]

	# перенаправление на главную страницу
	redirect to '/'	
end	

# вывод информации о посте
get '/details/:id' do
	post_id = params[:post_id]
	erb "Displaying information for post with id #{post_id}"
end