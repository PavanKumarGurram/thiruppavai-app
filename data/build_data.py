#!/usr/bin/env python3
"""Merge Tamil + transliteration + titles/ragas/meanings into pasurams.json."""
import json

ta = json.load(open('tamil-final.json', encoding='utf-8'))
tr = json.load(open('translit-raw.json', encoding='utf-8'))
trmap = {v['n']: v['lines'] for v in tr}

RAGAS = {1: 'Nattai', 2: 'Gowla', 3: 'Arabhi', 4: 'Varali', 5: 'Sri',
         6: 'Sankarabharanam', 7: 'Bhairavi', 8: 'Dhanashri',
         9: 'Hameer Kalyani', 10: 'Thodi', 11: 'Huseni', 12: 'Kedaragowla',
         13: 'Atana', 14: 'Ananda Bhairavi', 15: 'Begada', 16: 'Mohanam',
         17: 'Kalyani', 18: 'Saveri', 19: 'Sahana', 20: 'Senchuruti',
         21: 'Nadanamakriya', 22: 'Yamuna Kalyani', 23: 'Bilahari',
         24: 'Sindhu Bhairavi', 25: 'Behag', 26: 'Kuntalavarali',
         27: 'Poorvi Kalyani', 28: 'Kambhoji', 29: 'Madhyamavathi',
         30: 'Surutti'}

TITLE_EN = {1: 'The Vow Begins', 2: 'Rules of the Vow',
            3: 'The World-Measurer', 4: 'Lord of the Rains',
            5: 'The Dark Lord of Mathura', 6: 'Dawn Has Come',
            7: 'Wake, Lazy Girl', 8: 'The Morning Call',
            9: 'The Girl in the Mansion', 10: 'The Heavy Sleeper',
            11: 'The Golden Creeper', 12: 'The Buffalo Girl',
            13: 'To the Bathing Field', 14: 'The Backyard Pond',
            15: 'The Young Parrot', 16: 'Open the Temple Door',
            17: 'Wake, Nandagopa', 18: 'Nappinnai, Open the Door',
            19: 'The Lamplit Chamber', 20: 'Wake, Victorious One',
            21: 'The Generous Cows', 22: 'Like the Rising Sun and Moon',
            23: "The Lion's Waking", 24: 'Praise to the Feet',
            25: 'Born to One Mother', 26: 'What We Ask For',
            27: 'The Rewards of the Vow', 28: 'Our Bond With You',
            29: 'We Are Yours', 30: 'The Tamil Garland'}

MEANINGS = {
1: "On this auspicious Margazhi morning, the wealthy cowherd girls are called to bathe and join the vow — to sing of Narayana, the son of Nandagopa and the lion-cub of the beautiful-eyed Yashoda, whose face glows like the sun and moon.",
2: "Hear the rules of our vow, all who live in this world: we will sing of the Lord who sleeps on the milky ocean, eat no ghee or milk, wear no flowers, do no wrong, give alms generously, and think only of rising higher.",
3: "If we sing of the Lord who strode across the worlds and bathe in this vow, the rains will fall three times a month, the tall red paddy will flourish with fat kayal fish among the blossoms, and our prosperity will never leave.",
4: "O lord of the rains, draw water from the ocean and rise dark as the Primal Lord, flash like the discus in Vishnu's hand and thunder like His conch — then pour down on the world so we may bathe joyfully in Margazhi.",
5: "Meditating on Krishna — the wonder of Mathura, the lord of the Yamuna's banks, the lamp of the cowherd clan whom Yashoda raised as the lamp of her womb — and worshipping Him with pure hearts, all our past and future sins will burn away like cotton in fire.",
6: "The birds are chirping, the temple conch resounds — wake up, girl! The sages and yogis have risen meditating on Vishnu who sleeps on the serpent in the ocean of milk. Our hearts have melted into Him; come, let us be cooled in His name.",
7: "The chattering of birds everywhere, the clatter of churns — can you not hear it, lazy girl? The cowherd women are churning curd, making the noise ring out. Wake, bride of our Lord, and sing of Narayana and Kesava.",
8: "The eastern sky reddens and the buffaloes wander out to graze; the other girls have gone ahead without waiting. We have come calling you with joy — wake, girl! Let us sing of Him who tore open the demon's mouth and crushed the wrestlers, and be graced.",
9: "O daughter of our uncle, asleep in your gem-lit mansion with lamps all around and incense in the air — open your jeweled door! Wake her, aunt! We sing His many names — the great Enchanter, Madhava, Vaikuntha — to rouse her.",
10: "You promised to wake us first, yet you sleep on like Kumbhakarna! Open the door — we sing of Narayana crowned with fragrant tulasi, the meritorious one who will grant us the drum we seek.",
11: "O faultless daughter of the cowherds, golden creeper, girl with hips like a coiled snake and the gait of a peacock! Your friends have all come into your courtyard to sing of the cloud-hued Lord — why do you sleep on, dear bride?",
12: "The young buffaloes low for their calves and milk streams through the streets, yet you will not open your mouth to sing of Him who in anger destroyed Lanka's king. Wake from this great sleep — the whole street knows of it!",
13: "Singing the fame of Him who tore the bird-demon's beak and destroyed the evil rakshasa, all the girls have gone to the bathing field. Venus has risen and Jupiter has set, the birds are singing — bathe in the cold water and join us, abandoning all deceit.",
14: "In your backyard pond the red lilies have opened and the water-lilies have closed; the ascetics are heading to the temple to blow the conch. You promised to wake us first — rise, shameless eloquent girl, and sing of Him who bears conch and discus in His great hands, the lotus-eyed one.",
15: "“Are you still asleep, young parrot?” “Don't call me that, friends — I'm coming!” “We know your old boasts. Come quickly — have all come? They have come; count them yourself. Sing of the Enchanter who killed the strong and destroys His foes.”",
16: "O guard of Nandagopa's temple with its festooned gates, open the jeweled door! The dark-gem-hued Enchanter promised us the drum yesterday; we have come pure to sing Him awake. Don't turn us away with words — open the firmly shut door, good mother.",
17: "Wake, Nandagopa, our lord who gives clothes, water, and rice! Wake, Yashoda, tender sprout and lamp of the clan, our lady! Wake, lord of the celestials who tore through the sky and measured the worlds! Wake, Balarama of the golden anklets — none of you should sleep.",
18: "O Nappinnai, bride of Nandagopa's mighty son who never turns his shoulder in battle, fragrant-haired girl — open the door! The roosters have crowed everywhere and the koels coo on the jasmine bower. Come joyfully, your fine bangles ringing, to sing your husband's name.",
19: "O Nappinnai with flower-garlanded hair, resting on Krishna's flower-chest in the lamplit chamber on a soft cotton bed — open your mouth! How long will you keep your husband from waking? It is not right to be unable to bear parting even for a moment.",
20: "Wake, O Krishna who marched before the thirty-three gods to end their tribute, upright and mighty one who burns His foes! Wake, Nappinnai of gentle breasts, red lips and slender waist — give us your mirror and fan, and let your husband grant us the bath even now.",
21: "Wake, son of the great cowherd whose generous cows fill every vessel to overflowing with milk! Wake, steadfast great one, radiant sun among men — your foes, their strength broken, come helpless to your door; we have come praising you.",
22: "Kings of the wide world have come in pride to the foot of your bed, and like that assembly we too have come. Open your lotus eyes, small as bell-flowers, upon us — if you look at us with both eyes, like the rising moon and sun, the curse upon us will fall away.",
23: "As the noble lion sleeping in the rainy mountain cave wakes, opens its fiery eyes, shakes its fragrant mane, stretches, roars and strides out — so come, blue-lotus-hued Lord, from Your temple to Your splendid throne, and consider the purpose for which we have come.",
24: "Praise to the feet that measured this world! Praise to the strength that destroyed southern Lanka! Praise to the fame that kicked the cart-demon to death! Praise to the anklet that hurled the calf-demon! Praise to the virtue that lifted the hill as an umbrella! Praise to the spear in Your victorious hand! We have come today to take the drum, ever singing Your service — have mercy on us.",
25: "Born to one mother and in a single night hidden away to grow as another's son, You foiled the murderous thoughts of Kamsa, who could not bear it. We have come desiring You, O tall Lord who stood like fire in his belly — grant us the drum, and singing Your fitting wealth and service, our suffering will end in joy.",
26: "O dark-gem-hued Lord, hear what we need from the elders for our Margazhi bath: conches like Your milk-white Panchajanya, great drums, singers of many Pallandus, lamps, banners and canopies — O You who slept on the banyan leaf, grant them in grace!",
27: "O Govinda of undiminished glory who conquers those who will not join, singing You we shall win the drum — and then, praised by the whole land, we will wear bangles, armlets, earrings and anklets and many jewels, dress in fine clothes, and together eat milk-rice with ghee poured till it runs down our forearms, and be cooled.",
28: "We who follow the cows to the forest and graze alongside them, ignorant cowherd folk, have the merit of Your birth among us. O faultless Govinda, our kinship with You can never be undone — do not be angry that we, childish in love, called You by familiar names; grant us the drum, O Lord.",
29: "Hear what we seek, coming at dawn to serve You and praise Your golden lotus feet: born in the clan that tends cattle, You cannot refuse us Your service. Not just today's drum, Govinda — for all births to come, seven times seven, we are Yours; we will serve only You; take away all our other desires.",
30: "Goda of beautiful Srivilliputhur, daughter of Vishnuchitta who wears the cool lotus garland, sang this Tamil garland of thirty about Madhava who churned the surging ocean and Kesava, worshipped by moon-faced maidens wearing fine jewels. Those who recite it unfailingly will receive the grace of Thirumal, the wealthy red-eyed Lord, everywhere and rejoice."
}

out = []
for v in ta:
    n = v['n']
    out.append({
        'n': n,
        'title': v['title'],
        'titleEn': TITLE_EN[n],
        'raga': RAGAS[n],
        'tamil': v['tamil'],
        'translit': trmap[n],
        'meaning': MEANINGS[n],
    })

assert len(out) == 30
assert all(len(p['tamil']) == 8 and len(p['translit']) == 8 for p in out)
json.dump(out, open('pasurams.json', 'w', encoding='utf-8'),
          ensure_ascii=False, indent=1)
print('pasurams.json: 30 records OK')
