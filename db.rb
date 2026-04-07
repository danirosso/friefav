require 'pg'
user = %x[echo $USER]
user = user.chomp

def db
PG.connect(
  dbname: 'friefavs',
  user: user,
)
end
