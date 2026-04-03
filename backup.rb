require 'pg'
db = PG.connect(
  dbname: 'friefavs',
  user: 'rosso',
)

choice = nil

loop do
  puts "Are you already a friend? [y/N]"
  choice = gets.chomp
  choice.downcase!
  break if choice == 'y' || choice == 'n' || choice.empty?
end

if choice == 'n' || choice.empty?
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

else 

  choice = nil
  loop do
    menu = ['d','e','r','s']
    puts "Do you want to [D]elete, [E]dit, [R]ead or [S]ee the friends favorite lists?"
    choice = gets.chomp
    choice = choice.chr
    choice.downcase
    if menu.include?(choice)


      case choice
      when 'd'
        puts "Delete!"
      when 'e'
        puts "Edit!"
      when 'r'
        puts "Read!"
      when 's'
        choice = nil
        puts "See!"
        page = 5 
        see = db.exec("SELECT * FROM friends ORDER BY id ASC LIMIT 5 OFFSET $1")[page];
        see.each do |friend|
          puts "ID: #{friend['id']} | Name: #{friend['name']}"
          puts "Album: #{friend['favorite_album']} | Book #{friend['favorite_book']}\n\n"
          loop do
            menu = ['n', 'p', 'q']
            puts "\t[N]ext page | [P]revius page | [Q]uit"
            choice = gets.chomp
            choice.downcase
            choice = choice.chr
            if menu.include?(choice)
              case choice
              when 'n'
                puts "Next page!"
                page *= 5
              when 'p'
                puts "Previous page!"
                page /= 5
              when 'q'
                puts "Quit!"
                break
              end
            end

          end
        end
        break
      end
    end
  end
