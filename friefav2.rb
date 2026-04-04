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
    menu = ['d','u','c','s','q']
    puts "Do you want to [d]elete, [u]pdate, [c]check out or [s]ee the friends favorite lists?"
    choice = gets.chomp
    choice = choice.chr
    choice.downcase
    break if menu.include?(choice)
  end

  case choice
  when 'd'
    puts "Delete!"
    removeFriend(db)
  when 'u'
    puts "Update!"
    updateFriend(db)
  when 'c'
    puts "Check out!"
    checkOut(db)
  when 's'
    puts "See!"
    seeFriends(db)
  end
  return choice
end

def addFriend (db)
  puts "Enter the friend name:"
  name = gets.chomp
  puts "Now, for  #{name} insert a  music album:"
  album = gets.chomp
  puts "That's a nice one! Now please insert a  book:"
  book = gets.chomp
  puts "That's cool, for #{name}, the album is #{album}, and the book is #{book}, he seems like a nice dude!\n"

  db.exec_params(
    "INSERT INTO friends (name, favorite_book, favorite_album) VALUES ($1, $2, $3)", [name, book, album]
  )
  puts "I've saved the preferences in my database, we have now one more friend (:"
end

def seeFriends(db)
  page = 0
  loop do
    offset = page * 5
    puts "#{offset}"
    friends = db.exec_params("SELECT * FROM friends ORDER BY id ASC LIMIT 5 OFFSET $1", [offset])
    friends.each do |friend|
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
    puts "Do you want to see the [N]ext page, the [p]revious one or go [b]ack to the main menu?"
    choice = gets.chomp
    if choice.empty?
      choice = 'n'
    end
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

def removeFriend(db)
  action = nil
  id = nil
  puts "I'll assume you made a mistake, you can't delete friends!\n\n"
  friends  = getId(db)
  friends.each do |friend|
    action = "delete #{friend['name']}'s entry"
    id = friend['id']
  end
  choice = yesNo(action)
  if choice == 'y'
    db.exec_params("DELETE FROM friends WHERE id = $1", [id])
    puts "#{action} was successfull ):"
    mainMenu(db)
  else
    puts "That's right! You can't remove a friend!"
    mainMenu(db)
  end
end

def getId(db)
  puts "Enter the ID or leave it blank to go back to the main menu"
  id = gets.chomp
  if id.empty?
    mainMenu(db)
  end
  friends = db.exec_params("SELECT * FROM friends WHERE id = $1", [id])
  while friends.ntuples == 0
  puts "Wrong ID, enter it again or leave it blank to go back to the main menu"
  id = gets.chomp
  if id.empty?
    mainMenu(db)
  end
  friends = db.exec_params("SELECT * FROM friends WHERE id = $1", [id])
  break if friends.ntuples != 0
  end
  return friends
end

def yesNo(action) 
  choice = nil
  loop do
    menu = ['y', 'n']
    puts "Do you want to #{action}\n \t [y]/[N]"
    choice = gets.chomp
    if choice.empty? 
      choice = 'n'
    end
    choice = choice.downcase
    choide = choice[0]
    break if menu.include?(choice)
  end
  return choice
end


def updateFriend(db)
  puts "It's nice to change once in a while!"
  friends = getID(db)
end

def checkOut(db)
  action = "check out another friend"
  puts "So you want to know more about a friend, huh? (:"
  friends = getId(db)
  friends.each do |friend|
    puts "Name: #{friend['name']} | Book: #{friend['favorite_book']} | Album: #{friend['favorite_album']}"
  end
  choice = yesNo(action)
  while choice == 'y'
    friends = getId(db)
    friends.each do |friend|
      puts "Name: #{friend['name']} | Book: #{friend['favorite_book']} | Album: #{friend['favorite_album']}"
    end
    choice = yesNo(action)
    break if choice == 'n'
    mainMenu(db)
  end
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
