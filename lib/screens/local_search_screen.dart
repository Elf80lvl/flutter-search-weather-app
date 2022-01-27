import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocalSearchScreen extends StatefulWidget {
  const LocalSearchScreen({Key? key}) : super(key: key);

  @override
  _LocalSearchScreenState createState() => _LocalSearchScreenState();
}

class _LocalSearchScreenState extends State<LocalSearchScreen> {
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
          child: Text('Local'),
        ),
      ),
    );
  }
}

class CitySearch extends SearchDelegate<String> {
  final cities = [
    'Berlin',
    'Paris',
    'Munich',
    'Hamburg',
    'London',
  ];

  final recentCities = [
    'Munich',
    'Hamburg',
    'London',
  ];

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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_city,
            size: 120,
          ),
          SizedBox(height: 32),
          //* query - object from SearchDelegate, holds value of searchbar text
          Text(
            query,
            style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? recentCities
        : cities.where((city) {
            final cityLower = city.toLowerCase();
            final queryLower = query.toLowerCase();
            return cityLower.startsWith(queryLower);
          }).toList();

    return buildSuggestionsSuccess(suggestions);
  }

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
}
