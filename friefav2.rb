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

def mainMenu
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
  when 'e'
    puts "Edit!"
  when 'r'
    puts "Read!"
  when 's'
    puts "See!"
  end
  return choice
end

def addFriend
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



choice = initMenu
loop do
  if choice == 'y'
    mainMenu
  else 
    addFriend
    choice == 'y'
  end
end
