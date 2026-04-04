require 'pg'
user = %x[echo $USER]
user = user.chomp

db = PG.connect(
  dbname: 'friefavs',
  user: user ,
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
    menu = ['a','d','u','c','s','q']
    puts "Do you want to [a]dd a friend, [d]elete, [u]pdate, [c]check out or [s]ee the friends favorite lists?"
    choice = gets.chomp
    choice = choice.chr
    choice.downcase
    break if menu.include?(choice)
  end

  case choice
  when 'a'
    puts "Add!"
    addFriend(db)
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
  numberRows = nil
  loop do
    offset = page * 5
    if offset < 0 
      offset = 0
    end
    friends = db.exec_params("SELECT * FROM friends ORDER BY id ASC LIMIT 5 OFFSET $1", [offset])
    friends.each do |friend|
      puts "ID: #{friend['id']} | Name: #{friend['name']}"
      puts "Album: #{friend['favorite_album']} | Book #{friend['favorite_book']}\n\n"
      numberRows = friends.ntuples
    end
    page = paginator(db,page)
    if numberRows < offset
      page -=1
      puts "We've ran out of friends to display, you can add more so this doesn't happen again D:"
    end
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
  choice = nil
  id = nil
  puts "It's nice to change once in a while!"
  friends = getId(db)
  friends.each do |friend|
    puts "Name: #{friend['name']} | Book: #{friend['favorite_book']} | Album: #{friend['favorite_album']}"
    id = "#{friend['id']}" 
  end
  menu = ['a', 'b']
  loop do
    puts "Which favorite do you want to change? [a]lbum or [b]ook?"
    choice = gets.chomp
    if choice.empty?
      mainMenu(db)
    end
    choice = choice.downcase
    choice = choice[0]
    break if menu.include?(choice)
    puts "You have to select either [a]lbum or [b]ook, leave empty to go back to the main menu"
  end
  case choice
  when 'a'
    subject = "favorite_album"
  when 'b'
    subject = "favorite_book"
  end
  action = "update the #{subject}?"
  choice = yesNo(action)
  if choice == 'y'
    puts "Enter the new name: "
    newFav = gets.chomp
    db.exec_params("UPDATE friends SET #{subject}  = $1  WHERE id = $2", [newFav, id])
  else
    mainMenu(db)
  end
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
