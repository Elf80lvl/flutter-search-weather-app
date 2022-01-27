import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:search/api/weather_api.dart';
import 'package:search/model/weather.dart';

class NetworkSearchScreen extends StatefulWidget {
  const NetworkSearchScreen({Key? key}) : super(key: key);

  @override
  _NetworkSearchScreenState createState() => _NetworkSearchScreenState();
}

class _NetworkSearchScreenState extends State<NetworkSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App bar title'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              //* showSearch comes with Flutter
              final results =
                  await showSearch(context: context, delegate: CitySearch());

              print('Results: $results');
            },
            icon: Icon(Icons.search),
          ),
        ],
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Text('Network'),
        ),
      ),
    );
  }
}

class CitySearch extends SearchDelegate {
  //*what to build to the right side of the search bar (close (clear) button in this case which clears the serarch fiels or closes the search if it's empty)
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          if (query.isEmpty) {
            //*clear the search field by pressing the cross button
            //* the second argument of the close function returns in showSearch()
            close(context, '1');
          } else {
            query = '';
            //* show suggestions page after clearing the search text fiels (clicking cross button)
            showSuggestions(context);
          }
        },
        icon: Icon(Icons.clear),
      )
    ];
  }

  //*what to build on the left side (back button in this case which closes the search)
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        return close(context, '1');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  //*what to show as a result
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<Weather>(
        future: WeatherApi.getWeather(city: query),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Container(
                  child: Text('Error!'),
                );
              } else {
                return buildResultSucces(snapshot.data);
              }
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) => FutureBuilder<List<String>>(
      future: WeatherApi.searchCities(query: query),
      builder: (context, snapshot) {
        //* if there is no text in the search field show widget that says that
        if (query.isEmpty) {
          return buildNoSuggestions();
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError || snapshot.data!.isEmpty) {
              return buildNoSuggestions();
            }
            //*snapshot.data - List of Strings of suggestions
            return buildSuggestionsSuccess(snapshot.data!);
        }
      });

  Widget buildSuggestionsSuccess(List<String> suggestions) => ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final queryText = suggestion.substring(0, query.length);
        final remainingText = suggestion.substring(query.length);
        return ListTile(
          //* what to do by clicking the one of the suggestions
          onTap: () {
            //* pick and use in query which is text in search
            query = suggestion;

            //close(context, suggestion);

            // //*go to result page
            //Navigator.push(context, MaterialPageRoute(builder: (context)=> ResultPage(suggestion)));

            //* build resulsts page instead of suggestions
            showResults(context);
          },
          leading: Icon(Icons.location_city),
          //title: Text(suggestion),
          title: RichText(
            text: TextSpan(
                text: queryText,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                children: [
                  TextSpan(
                    text: remainingText,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                    ),
                  )
                ]),
          ),
        );
      });

  Widget buildNoSuggestions() => Center(
        child: Text(
          'No suggestions',
          style: TextStyle(color: Colors.grey),
        ),
      );

  Widget buildResultSucces(Weather? weather) {
    return Center(
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.center,

        children: [
          SizedBox(height: 64),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${weather!.city}, ',
                style: TextStyle(fontSize: 36),
              ),
              Text(
                '${weather.degrees} ℃',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Icon(weather!.icon, size: 56),
          SizedBox(height: 18),
          Text(
            weather.description,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
