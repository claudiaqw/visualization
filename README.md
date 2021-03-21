# Práctica de Visualización y *Open Data*
### Máster en Data Science y Big Data 
### Claudia Quintana Wong

## Introducción

Este trabajo se centra en la visualización de datos tomados de la API de Last.fm

El código del proyecto está disponible en https://github.com/claudiaqw/visualization.


## Carga y tratamiento de información
En esta sección se describe el proceso de carga y transformación de los datos. Se utilizaron tres métodos de extracción de información: a través de la API de last.fm, haciendo web scrapping y lectura de ficheros estáticos en formato csv y geojson. En todos los casos los ficheros creados o descargados se encuentran en el directorio *data* de la aplicación.

### API last.fm
En el archivo get_data.ipynb se pueden encontrar todas las funcionalidades implementadas para obtener los datos de la API. Fue seleccionado como Pytho de programación porque last.fm ofrece una api amigable disponible en este lenguaje.
De la APi fueron utilizados los siguientes métodos:

* **chart.gettopartists**: Este método nos permite obtener toda la lista de artistas ordenados de acuerdo a la variable **playcount**, que indica la cantidad de veces que ha sido escuchado alguna de las canciones del artista. El resultado se puede constatar en el archivo *artists.csv*. De esta método se obtuvierob las siguientes variables:
    * name: nombre del artista
    * playcount: cantidad de veces que han sido escuchadas alguna de sus canciones
    * listeners: cantidad de usuarios que han escuchado alguna de sus canciones
    * mbid: 
    * url: url dentro de la web last.fm
    * streamable: 
    * image: url de la imagen en la web    
    Además con el objetivo de ampliar la información acerca de los artistas se decide integrar estos datos con la informacion del método **artist.getTopTags**. De ahí se sleccionaron las etiquetas más comunes relacionadas con cada artista, datos que se encuentran en las columnas $tag_{i}$
* **chart.getTopTracks**: Este método fue consultado de manera análoga al anterior, solo que para obtener una gran cantidad de canciones disponibles en la web. Asimismo, se utilizó el método **track.getTopTags** para añadir información respecto a etiquetas añadidas por usuarios de la web. 
* **geo.getTopArtists**: Este método da los artistas más populares en last.fm por país ordenados de acuerdo a su impacto. Recibe como parámetro el nombre de los países en formato ISO 3166-1. Para obtener el nombre de los países en dicho formato fue necesario recurrir a una fuente externa, en este caso, la lista de países fue tomada de https://pkgstore.datahub.io/core/country-list/data_csv/data/d7c9d7cfb42cb69f4422dec222dbbaa8/data_csv.csv, este fichero se encuentra en el directorio *data* de la aplicación. El resultado de este preprocesamiento se encuentra en el fichero *top_artists_per_country.cvs*. El archivo resultante es *tracks.csv*. De este método se obtuvo información tabular respecto a las siguientes variables:
    * country: nombre del país en formato ISO 3166-1.
    * code: código del país de acuerdo al formato ISO 3166-1
    * artist: nombre del artista
    * listeners: cantidad de sequidores
    * rank: *ranking* de acuerdo al país.
* **geo.getTopTracks**: Este método fue utilizado de manera análoga al anterior y el resultado se encuentra en *top_tracks_per_country.csv*.
* **user.getRecentTracks**: Esta funcionalidad permite obtener información de un usuario determinado sobre sus últimas canciones escuchadas.

### Web scrapping

Aunque la API last.fm dispone de distintos métodos para acceder a la información, no ofrece datos agregados según la fecha que faciliten el análisis temporal. Las únicas funciones que ofrecen detalles temporales son las relativas a los usuarios y para ser consultadas requieren el nombre de usuarios reales.

Con el objetivo de obtener nombres de usuarios reales fue necesario acudir a la técnica de *web scrapping*. La idea es a partir de una lista de usuarios inicial, navegar por sus *followers* y *followings* para ir aumentando dicha lista y aplicar este algoritmo recursivamente. En este caso, se llegó hasta un nivel de profundidad igual a 2 a partir de una lista tomada de https://www.reddit.com/r/lastfm/comments/7kgc86/list_of_users_by_scrobbles/. Las funcionalidades implementadas se encuentran en el fichero *scrapper.ipynb*. Como resultado de la aplicación de este enfoque se obtuvo una lista compuesta por 25.000 usuarios que puede ser consultada en el fichero *usernames.csv*. Esta información se utiliza en conjunto con el método **user.getRecentTracks** para obtener un histórico de las canciones escuchadas en last.fm

### Lectura de ficheros estáticos
En este proyecto fue necesaria la lectura de dos ficheros estáticos, como fue explicado con anteroridad. El fichero 
https://pkgstore.datahub.io/core/country-list/data_csv/data/d7c9d7cfb42cb69f4422dec222dbbaa8/data_csv.csv para obtener el nombre de los países de acuerdo al estándar ISO 3166-1. Asimismo, para la visualización cartógrafica se toma el fichero https://github.com/johan/world.geo.json.


## Visualización estática


## visualización dinámica