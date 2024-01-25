#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.sqlite'
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
	# Создает таблицу Posts если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    author TEXT,
    created_date DATE,
    content TEXT
)'
	# Создает таблицу Comments если таблица не существует
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments 
	(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    author TEXT,
    content TEXT,
    created_date DATE,
    post_id INTEGER
)'

end

get '/' do
	# выбираем список постов из БД
	@results = @db.execute 'select * from Posts order by id desc'
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
	# получаем переменные из post-запроса
	author = params[:author]
	content = params[:content]

	if author.size <= 0
		  @error = 'Fill in the Author field!'	
		  return erb :new

	elsif content.size <= 0
		  @error = 'Fill in the Comment field!'	
		  return erb :new
	end

# сохранение данных в БД
  @db.execute 'insert into Posts (author, content, created_date) values (?, ?, datetime())',[author, content]
    
	# перенаправление на главную страницу
	redirect to '/'	
end	

# вывод информации о посте
get '/details/:post_id' do

	# получаем переменную из url
	@post_id = params[:post_id]
	# получаем список постов 
	# (у нас будет только один пост)

	@results = @db.execute 'select * from Posts where id = ?', [@post_id]

# выбираем этот один пост в переменную @row
	@row = @results[0]

	# выбираем комментарии пост в переменную @row
	@comments = @db.execute 'select * from Comments where post_id = ? order by id',[@post_id]

	# возвращаем представление details.erb
	erb :details
end

# обработчик из post-запроса /details
#(браузер отправляет данные на сервер, мы их принимаем)
post '/details/:post_id' do

	@post_id = params[:post_id]
	author = params[:author]
	content = params[:content]

	@db.execute 'insert into Comments (content, created_date, post_id)
	 values (?,datetime(), ?)', [content, @post_id]

	# перенаправление на страницу поста
		redirect to ('/details/' + @post_id)
end