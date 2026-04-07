require 'pg'


def db
  user = %x[echo $USER]
  user = user.chomp
PG.connect(
  dbname: 'friefavs',
  user: user,
)
end
