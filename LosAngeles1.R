"En este archivo se encuentra el código de:
-Data Cleaning
-Exploratory Data Analysis
-Primeros mapas de Los Ángeles
-KDE estimador
-Mapa de calor
"


datos <- read.csv("C:/Users/Mario/Desktop/Trabajo Espaciales/Crime_Data_from_2020_to_Present.csv")
library(lubridate)
library(tidyverse)

datos$DATE.OCC <- as.Date(datos$DATE.OCC, format="%m/%d/%Y %I:%M:%S %p")



# Cambiamos las codificaciones de las etnias de las victimas.
nuevos_valores <- c("Other Asian", "Black", "Chinese", "Cambodian", "Filipino", "Guamanian", "Hispanic/Latin/Mexican", "American Indian/Alaskan Native", "Japanese", "Korean", "Laotian", "Other", "Pacific Islander", "Samoan", "Hawaiian", "Vietnamese", "White", "Unknown", "Asian Indian")
datos$Vict.Descent <- factor(datos$Vict.Descent, levels = c("A", "B", "C", "D", "F", "G", "H", "I", "J", "K", "L", "O", "P", "S", "U", "V", "W", "X", "Z"), labels = nuevos_valores)

# create a vector of variable names to convert to factors
var_names <- c("Vict.Sex", "Vict.Descent", "Vict.Age", "AREA.NAME", "Premis.Cd","Premis.Desc", "Weapon.Desc", "Crm.Cd.Desc", "Status.Desc")

# use a for loop to convert each variable to a factor
for (var in var_names) {
  datos[[var]] <- factor(datos[[var]])
}

summary(datos)

# VICITMAS POR GENERO -----------------------------------------------------

# En la documentaicon del gobierno no se especifican el significado de los valores de h x, por lo que tendremos tan solo en cuenta F y M.
genero <- table(datos$Vict.Sex)
genero
#eliminamos los valores mal metidos y nos quedamos solo con hombres y mujeres
genero <- genero[c(2,4)]
genero2 <- as.data.frame(genero)

mf <- datos %>% filter(datos$Vict.Sex == "F" | datos$Vict.Sex == "M")
#filttramos por mujeres
a<- mf %>%
  filter(Vict.Sex=="F") %>%
  group_by(Vict.Sex,Crm.Cd.Desc)
"AQUI BUSCAR EN AA EL NUMERO DE CASOS DE VIOLENCIA DE GENERO."
summary(a$Crm.Cd.Desc)
aa <- count(a$Crm.Cd.Desc)
library(tidyverse)
#LOS 10 PRINCIPALES  DE CADA SEXO
mf %>%
  filter(Vict.Sex=="F") %>%
  group_by(Vict.Sex,Crm.Cd.Desc) %>%
  tally() %>%
  ungroup() %>%
  mutate(Vict.Sex = reorder(Vict.Sex,n)) %>%
  arrange(desc(n)) %>%
  head(10) %>%
  
  ggplot(aes(x = Vict.Sex["F"],y = n, fill =Crm.Cd.Desc)) +
  geom_bar(stat='identity') +
  labs(x = 'Sexo', y = 'Nº de incidentes', 
       title = '') +
  coord_flip() + 
  theme_bw() + theme(legend.position="top")

mf %>%
  filter(Vict.Sex=="M") %>%
  group_by(Vict.Sex,Crm.Cd.Desc) %>%
  tally() %>%
  ungroup() %>%
  mutate(Vict.Sex = reorder(Vict.Sex,n)) %>%
  arrange(desc(n)) %>%
  head(10) %>%
  
  ggplot(aes(x = Vict.Sex,y = n, fill =Crm.Cd.Desc)) +
  geom_bar(stat='identity') +
  labs(x = 'Sexo', y = 'Nº de incidentes', 
       title = '') +
  coord_flip() + 
  theme_bw() + theme(legend.position="top")

#Intimate partner = Violencia pareja sentimental.


options(scipen=999)
ggplot(genero2, aes(x=Var1, y = Freq, fill = Var1)) + 
  geom_bar(stat="identity")+
  scale_fill_manual(values=c("#fdbb84", "#2c7fb8"))+
  geom_text(aes(label=Freq), vjust=-0.5)+
  theme_minimal()+ theme(legend.position = "none")+
  xlab("")+ ylab("")+labs(title = " Distribución de género", caption = "Elaboración propia")



# CASOS POR AÑOS ----------------------------------------------------------


n20 <- nrow(filter(datos, year(datos$DATE.OCC)== 2020))
n21 <-nrow(filter(datos, year(datos$DATE.OCC)== 2021))
n22 <- nrow(filter(datos, year(datos$DATE.OCC)== 2022))
n23 <- nrow(filter(datos, year(datos$DATE.OCC)== 2023))

year <- c(2020,2021,2022,2023)
casos <- c(n20,n21,n22,n23)

casosdf <- data.frame(year,casos)
#HACER UNA TABLA.

library(gt)

# Crear la tabla utilizando kable()
gt_tbl <- gt(casosdf)

gt_tbl <- 
  gt_tbl %>%
  tab_header(
    title = "Número de crímenes en Los Ángeles") %>% 
  gt::cols_label(year = "Año",casos = "Nº de casos" ) %>%   tab_source_note(source_note = "Elaboración propia")

# Show the gt Table
gt_tbl



# CASOS POR ÉTNIA ---------------------------------------------------------


summary(datos$Vict.Descent)
etnia <- c("Other Asian (Not China)","Black","Chinese","Cambodian","Filipino","Guamanian","Hispanic/Latin/Mexican American",
           "American Indian/Alaskan Native","Japanese","Korean","Laotian","Other","Pacific Islander","Samoan","Hawaiian",
           "Vietnamese","White","Asian Indian")
n <- c(14736,98034,2467,47,2771,48,208609,649,924,3555,44,53713,180,38,131,665,139839,326)

df_etnia <- data.frame(etnia, n )

df_ordenado <- df_etnia[order(df_etnia$n, decreasing = TRUE),]

df_ordenado <- df_ordenado[1:5,]


library(ggplot2)
library(ggrepel)
library(tidyverse)

# Get the positions
df2 <- df_ordenado %>% 
  mutate(csum = rev(cumsum(rev(n))), 
         pos = n/2 + lead(csum, 1),
         pos = if_else(is.na(pos), n/2, pos))

ggplot(df_ordenado, aes(x = "" , y = n, fill = fct_inorder(etnia))) +
  geom_col(width = 1, color = 1) +
  coord_polar(theta = "y") +
  scale_fill_brewer(palette = "Pastel1") +
  geom_label_repel(data = df2,
                   aes(y = pos, label = paste0(n)),
                   size = 4.5, nudge_x = 1, show.legend = FALSE) +
  guides(fill = guide_legend(title = "Étnia")) +
  theme_void()

# EDADES DE LAS VICTIMAS --------------------------------------------------

library(dplyr)
library(ggplot2)

datos$Vict.Age <- as.numeric(datos$Vict.Age)
summary(datos$Vict.Age)

summary(as.factor(datos$Vict.Age))
#Vemos como hay una gran cantidad de victimas que tienen 3 años, por lo que pensamos que se debe a un error de introduccion
# de datos en el sistema, por lo que a la hora de realizar el gráfico no tendremos en cuenta dichas observaciones.



datos %>% group_by(Vict.Age) %>% filter(Vict.Age > 3) %>% count(Vict.Age) %>%
  ggplot(aes(x = Vict.Age, y = n)) + geom_bar(stat = "identity", fill="#69b3a2")+
  geom_vline(aes(xintercept = median(datos$Vict.Age),
                 color = "media"),
             linetype = "dashed",
             size = 1)+
  scale_x_continuous(n.breaks = 20)+ xlab("Edad")+ ylab("Víctimas")+ labs(color ="")+
  theme_minimal()

mean(datos$Vict.Age)
median(datos$Vict.Age)
sum(datos$Vict.Age< 30)
sum(datos$Vict.Age>30)

# CRIMENES POR AREA -------------------------------------------------------

casos_area <- as.data.frame(summary(datos$AREA.NAME))

df3 <- casos_area %>% 
  mutate(csum = rev(cumsum(rev(`summary(datos$AREA.NAME)`))), 
         pos = `summary(datos$AREA.NAME)`/2 + lead(csum, 1),
         pos = if_else(is.na(pos), `summary(datos$AREA.NAME)`/2, pos))
'
ggplot(casos_area, aes(x = "" , y = `summary(datos$AREA.NAME)`, fill = fct_inorder(rownames(casos_area)))) +
  geom_col(width = 1, color = 1) +
  coord_polar(theta = "y") +
  scale_fill_brewer(palette = "Pastel1") +
  geom_label_repel(data = df3,
                   aes(y = pos, label = paste0(`summary(datos$AREA.NAME)`)),
                   size = 4.5, nudge_x = 1, show.legend = FALSE) +
  guides(fill = guide_legend(title = "Barrio")) +
  theme_void()
'

ggplot(data=casos_area, aes(x=rownames(casos_area), y=casos_area$`summary(datos$AREA.NAME)`)) +
  geom_bar(stat="identity" , fill= rgb(0.1,0.4,0.5,0.7))+
  geom_text(aes(label=casos_area$`summary(datos$AREA.NAME)`), vjust=1.6, color="white", size=3.5)+
  xlab("Barrio")+ ylab("Casos")+
  theme_minimal()




# TIPO DE CRIMEN ------------
library(gt)
crimenes <- datos%>%
  group_by(Crm.Cd.Desc)%>%
  summarise(n=n())


ordenado <- crimenes[order(crimenes$n, decreasing = T), ]
gt(ordenado)
# MAPAS -------------------------------------------------------------------

library(sf) 
library(ggplot2)
library(dplyr) 
library(RColorBrewer) 
library(tidyverse) 
library(ggmap) 
library(png) 
library(magick)
library(cowplot)
library(knitr) 

LA <- st_read("C:/Users/Mario/Desktop/Trabajo Espaciales/City_Boundaries.shp") #WGS84
LA_city <- filter(LA, CITY_LABEL == "Los Angeles")
District <- st_read("C:/Users/Mario/Desktop/Law_Enforcement_Reporting_Districts.shp")

#HAY QUE BORRAR TODAS LAS QUE TIENEN LAS LATITUDES Y LONGITUD = 0 
datos <- datos %>% filter(LON != 0 | LAT != 0) 
"ESTE NO"
ggplot() +
  # Add the LA boundary shapefile
  geom_sf(data=LA_city) +
  # Add the crime point data +
  #geom_point(data=LAcrime, mapping = aes(x=LON, y=LAT), color="red") +
  # Add hex binned layer
  geom_hex(data=datos,
           mapping = aes(x=LON, y=LAT), bins=15, color="black")+
  scale_fill_fermenter(n.breaks=10,palette = "RdYlBu")+
  # No theme to remove lat/long coord axis
  theme_void()


ggplot() +
  geom_sf(data=LA_city) +
  geom_density_2d(data=datos,
                  mapping = aes(x=LON, y=LAT)) +
  theme_void()

ggplot() +
  geom_sf(data=LA) +
  geom_density_2d(data=datos,
                  mapping = aes(x=LON, y=LAT)) +
  theme_void()
library(leaflet)
library(leaflet.extras)
datos %>%
  leaflet() %>%
  addTiles() %>%
  addHeatmap(lng=datos$LON,lat=datos$LAT, blur =50, radius = 20)



# LO ROJO ES EL SKID ROW AHI VAMOS A ESTUDIAR.

# EESTUDIO DEL KDE ---------------------------------------------------------------------


map2<- ggplot() +
  geom_sf(data=LA) +
  stat_density_2d(data=datos,
                  geom = "polygon",
                  contour = TRUE,
                  aes(x=LON, y=LAT, fill = after_stat(level))
                  alpha = 0.6,
                  colour = "darkblue",
                   bins = 5) +
   scale_fill_distiller(palette = "RdYlBu", direction = -1,
                       breaks = c(20, 30, 40, 50, 60),
                       labels = c("Low","","Med","","High"),
                       name = "Density (KDE)") +
  theme_void() +
  ggtitle("Crimenes en la ciudad de Los Ángeles") +
  theme(legend.position = c(0.10, 0.25),
        legend.title = element_text(size=8),
        legend.key.size = unit(0.3, "cm"),
        plot.title = element_text(size=9, face="bold",hjust = 0.5, vjust= 1.5),
        plot.margin = rep(unit(0,"null"),4),
        panel.spacing = unit(0,"null"))

map2

library(leaflet)
library(leaflet.extras)


map1<- ggplot() +
  geom_sf(data=LA_city) +
  stat_density_2d(data=datos,
                  geom = "polygon",
                  contour = TRUE,
                  aes(x=LON, y=LAT, fill = after_stat(level)),
                  # Make transparent
                  alpha = 0.6,
                  # Contour line colour
                  colour = "darkblue",
                  # 5 bins used as this map will be smaller in main geovis
                  bins = 5) +
 scale_fill_distiller(palette = "RdYlBu", direction = -1,
                       breaks = c(20, 30, 40, 50, 60),
                       labels = c("Low","","Med","","High"),
                       name = "Density (KDE)") +
 theme_void() +
  ggtitle("Crimenes en la ciudad de Los Ángeles") +
  theme(legend.position = c(0.10, 0.25),
        legend.title = element_text(size=8),
        legend.key.size = unit(0.3, "cm"),
        plot.title = element_text(size=9, face="bold",hjust = 0.5, vjust= 1.5),
        plot.margin = rep(unit(0,"null"),4),
        panel.spacing = unit(0,"null"))

map1




# FRECUENCIA DISTRITOS ----------------------------------------------------------------
w <- table(datos$Rpt.Dist.No)
rep.dis <- as.data.frame(w)
length(unique(rep.dis$Var1))
head(rep.dis, 5)
library(classInt)
library(maptools)
library(rgdal)
library(tidyr)
library(RColorBrewer)
library("spdep")
library(plyr)
library(tmap)
"Frecuencia en los distritos"
DistrictLA <- District %>% filter(District$NAME == "Los Angeles")
DistrictLA <- merge(DistrictLA, rep.dis, by.x = "RD", by.y = "Var1", all.x = TRUE)
DistrictLA$Freq[is.na(DistrictLA$Freq)] <- 0
length(DistrictLA$Freq)

var <- DistrictLA$Freq
breaks <- classIntervals(var, n = 9, style = "fisher")
my_colours <- rev(brewer.pal(9, "RdBu"))
"Por Reporting Districts"
plot(DistrictLA, col = my_colours[findInterval(var, breaks$brks, all.inside = TRUE)],   
     axes = FALSE, border = NA, max.plot = 1, main = "")
legend(x = -200.7, y = 4000, legend = leglabs(breaks$brks), fill = my_colours, bty = "n", cex = 0.6, title = "")




