require 'pg'
db = PG.connect(
  dbname: 'friefavs',
  user: 'rosso',
)

def initMenu
  choice = nil

  loop do 
    menu = ['y', 'n']
    puts "Are you already a friend? [y/N]"
    choice = gets.chomp
    if choice.empty?
      choice = 'n'
    end
    choice = choice.downcase
    choice = choice[0]
    break if menu.include?(choice) 
  end
  return choice
end

def mainMenu(db)
  choice = nil

  loop do
    menu = ['d','e','r','s','q']
    puts "Do you want to [D]elete, [E]dit, [R]ead or [S]ee the friends favorite lists?"
    choice = gets.chomp
    choice = choice.chr
    choice.downcase
    break if menu.include?(choice)
  end

  case choice
  when 'd'
    puts "Delete!"
    mainMenu(db)
  when 'e'
    puts "Edit!"
    mainMenu(db)
  when 'r'
    puts "Read!"
    mainMenu(db)
  when 's'
    puts "See!"
    seeFriends(db)
  end
  return choice
end

def addFriend (db)
  puts "Enter your name:"
  name = gets.chomp
  puts "Now, #{name} insert your favorite music album:"
  album = gets.chomp
  puts "That's a nice one! Now please insert your favorite book:"
  book = gets.chomp
  puts "That's cool, #{name},  your favorite album is #{album}, and your favorite book is #{book}, you seem like a nice dude!\n"

  db.exec_params(
    "INSERT INTO friends (name, favorite_book, favorite_album) VALUES ($1, $2, $3)", [name, book, album]
  )
  puts "I've saved your preferences in my database, you are now a friend (:"
end

def seeFriends(db)
  page = 0
  loop do
    offset = page * 5
    puts "#{offset}"
    see = db.exec_params("SELECT * FROM friends ORDER BY id ASC LIMIT 5 OFFSET $1", [offset])
    see.each do |friend|
      puts "ID: #{friend['id']} | Name: #{friend['name']}"
      puts "Album: #{friend['favorite_album']} | Book #{friend['favorite_book']}\n\n"
    end
    page = paginator(db,page)
   end
  end

def paginator (db, page)
  menu = ['n', 'p', 'b']
  choice = nil
  loop do
    puts "Do you want to see the [N]ext page, the [P]revious one or go [B]ack to the main menu?"
    choice = gets.chomp
    choice = choice.downcase
    choice = choice [0]
    break if menu.include?(choice)
  end

  case choice
  when 'n'
    page +=1
  when 'p'
    if page > 0
      page -=1
    else
      page = 1
    end
    when 'b'
      mainMenu(db)
    end

    return page
  end

  choice = initMenu
  loop do
    if choice == 'y'
      mainMenu(db)
    else 
      addFriend(db)
      mainMenu(db)
    end
  end
