require 'pg'


def db
PG.connect(
  user = %x[echo $USER]
  user = user.chomp
  dbname: 'friefavs',
  user: user,
)
end
