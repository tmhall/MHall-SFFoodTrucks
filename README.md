# Author

My name is Miller Hall, and I'm a software architect/developer living in San Francisco.

# The Challenge

This is a freeform assignment.

Suggestions include
* Write a web API that returns a set of food trucks.
* Write a web frontend that visualizes the nearby food trucks for a given place.
* Create a CLI that lets us get the names of all the taco trucks in the city.
* Create system that spits out a container with a placeholder webpage featuring the name of each food truck to help their marketing efforts.

The source data is located at
* [San Francisco's food truck open dataset](https://data.sfgov.org/Economy-and-Community/Mobile-Food-Facility-Permit/rqzj-sfat/data) 
* [CSV dump of the latest data](https://data.sfgov.org/api/views/rqzj-sfat/rows.csv)

# Approach

This project amuses me because I do live in SF.  I'm therefore focussing my solution on something that would be immediately useful for myself, being able to geo locate food trucks.

I'm doing just a CLI for now as that allows me to focus on features instead of delivery platform.  I would like there to be filters for "open now" and for style of food.  However, my casual observation of the data shows that the open times would require sanitizing, so I'm probably just going to focus on geo location for initial work.
