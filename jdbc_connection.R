
###R ÜZERİNDE DB BAĞLANTISI


## A. Oracle DB ile JDBC Bağlantısı Kurma 

#0.ADIM : Oracle'ın download sayfasından ojdbc6.jar dosyasını locale indirip onun pathini aşağıdaki 
#         drv alanında 2.parametre olarak gireriz. dbConnect fonksiyonuyla da bağlanacağımız db 
#         bilgilerini içeren jdbc stringini gireriz.

#1.ADIM : DB conncetion tanımlamasından önce ilgili paket yüklemesi va kullanılacak kütüphanenin eklemesi yapılır;
install.packages('RJDBC')
library(RJDBC)

#2.ADIM : Bağlanılacak DB'nin hangi driver ile çalışacağını, bu driver'ın localimizde nerede olduğu tanımlanır;
drv <- JDBC("oracle.jdbc.driver.OracleDriver", "D:\\ojdbc6.jar", identifier.quote = NA)

#3.ADIM : Bağlantı sağlanacak DB için jdbc connection stringi, ilgili şema ve şifre bilgisi tanımlanır;
conn <- dbConnect(drv, "jdbc:oracle:thin:@//<host>:<port>/<service_name>", "<schema>", "<password>")

#4.ADIM : Erişim sağlandı ve ilk sorgumuzu aşağıdaki gibi DB'ye gönderebiliriz;
dbGetQuery(conn, "SELECT COUNT(*) FROM <schema>.PERSON")


## B. Kaynak DB'den Alınan Veri Setini İşleyip DB'ye Yazma; 

#1.ADIM : DB tablosu dataframe'e atanır;
df <- data.frame(dbGetQuery(conn, "SELECT * FROM <schema>.PERSON"))

#2.ADIM : Aggregate işlemi ile ülkelerin yaş ve maaş ortalamalarını alan dönüşüm yapılır;
df_agg <- aggregate(df[,2:3], list(COUNTRY = df$COUNTRY),mean)

#3.ADIM : DB'de yaratacağımız tablo ile aynı isimde bir tablo var mı? var ise silinir;
if (dbExistsTable(conn, "temp_agg"))
  dbRemoveTable(conn, "temp_agg")

#4.ADIM : Tablonun DB'de ki varlığı kontrol edildikten (varsa silindikten) sonra tablomuz yaratılır;
dbWriteTable(conn, name = "temp_agg", value = df_agg, row.names = FALSE)
