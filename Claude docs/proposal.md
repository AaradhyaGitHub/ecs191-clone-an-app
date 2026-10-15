Proposal: A Clone of AMP Park
Name: Aaradhya Poudyal
Platform: iOS (Swift)
The App
AMP Park is a mobile payment platform that lets drivers pay for parking and extend sessions remotely. Students, professors, and visitors who drive to UC Davis rely on it to find appropriate parking zones and pay for regulated campus parking.
The Fundamental Problem the app currently addresses

1. Eliminating friction and physical barriers: Removes the inconvenience of waiting at physical kiosks or outdated parking booths that only accept coins.
2. Navigating complex campus rules: Simplifies verifying digital affiliations (like student housing status or faculty roles) to apply valid parking discounts.
3. Managing time constraints: Enables users to monitor and extend their parking remotely so they don't have to rush back to feed a meter mid-lecture.

What I'll Keep

* Pay for parking by zone and buy permits: The app already does this well. It's straightforward to tap your current zone and buy a permit.
* Map view of lots and zones: Interacting with the map to find zones and lots is fairly intuitive.
* Active sessions and remote extensions: Easily the best feature of the app—very easy to follow and manage.
* Timely notifications: A fantastic communication system that gives users timely reminders before their time runs out.
* Saved vehicles and license plates: A simple one-time setup that saves time and stress for daily commuters.

What I'll Change or Remove
The key change: An Enhanced Search Feature
Consider this scenerio:
Tommy just transferred to UC Davis from SoCal and knows very little about Davis. He has his first class tomrrow at Olson Hall at 9am. He wants to know where he should park so he goes to AMP and searches for Olson Hall.
What AMP Does:
The app currently shows a parking lot all the way in Wisconsin. Matter of fact, as of today, the app doesn't recognize simple key locations within UCD such as: Olson Hall, Perter J Shields, Sol, Tercero, etc.
Tommy then has to:

1. Go to Google maps
2. Search for Olson Hall in Davis in Google Maps
3. Remember where it is on the Google map
4. Switch app to go back to AMP
5. Manually locate Olson Hall in the AMP map
6. Manually browse around Olson Hall to see valid zones nearby.
7. Eyeball the closest valid zone near Olson Hall
8. Remember where that lot is on the map
9. Switch app back to Google Maps and find that lot.
10. Navigate to that lot.

That's a lot. No pun intended.
My Proposal
If the app already knows whether a user is a UC Davis student and can see they are in Davis, why show lots on the other side of the country?
Just like the app lets users save their vehicle and payment methods, I want to enable students to save their lecture and discussion buildings.
Now, when Tommy opens AMP, he sees all his classes listed (with the building).
Since its Thursday morning at 9am, the app assumes Tommy is trying to get to his 10:30am ECS 191 class at Cruess Hall. The app recognizes he is a student (eligible for C-Zones) and uses the Haversine formula to rank the three closest C-zones around Cruess Hall. It renders three clean UI cards displaying:

* Drive time from his current location to each lot.
* Walking distance from the parking lot to his destination building.
* A Navigate button that opens Google Maps with his current location and destination pre-filled.

Additionally, I want to add a search layer above AMP's current search that recognizes popular campus landmarks (like Latitude, The Silo, the Memorial Union, Peter J. Shields, and the Arboretum) just like Google Maps does.
Ambitious Features (Time Permitting)

1. Lot Heatmaps: Show real-time traffic or busy-ness levels for each lot.
2. TAPS Sighting Crowd-Sourcing: Allow users to report TAPS officer sightings so if students see that a lot has a lot of TAPS sighting reported, its likely that the lot won't be checked anytime soon and they could get away with not paying for parking there.
3. Schedule Integration: Allow users to input their full class schedule to automatically find the most central parking spot—especially handy for students heading home between classes.
