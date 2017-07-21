# mop-agra
Grafiskā bibliotēka priekš ARM asamblera. 
Nodrošinātā funkcionalitāte:
  
  - Punkta zīmēšana. Iespēja zīmēt kadra buferī punktu ar norādīto krāsu. Papildus ir iespējams norādīt vai punkta kāsai ir nepieciešams pielietot kādu loģisko operāciju (and, or, xor) ar buferī jau esošo krāsu un tikai tad veikt zīmēšanu, izmantojot pixcolor_t struktūras “op” lauku.
  - Līnijas zīmēšana. Līnijas zīmēšanai izmantots Bresenhama algoritms: (https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm).
  - Trijstūra aizpildīšana. Trijstūra aizpildīšanai izmantots baricentriskā koordinātu metode, kura pārbauda vai punkts atrodas trijstūrī uz malas vai ārpus tā. Apskatīti tiek tikai tie punkti, kuri atrodas taisnstūrī, kurš ietver interesējošo trijstūri.
  - Riņķa līnijas zīmēšana. Riņķa līnijas zīmēšanai ir izmantots “Midpoint circle algorithm”. (https://en.wikipedia.org/wiki/Midpoint_circle_algorithm)

 Bibliotēkas demonstrējums konsolē izmantojot pseido-grafiku, kur:
  - melnās krāsas simbols ir tukšums ' ' (black)
  - baltās krāsas simbols ir zvaigznīte '*' (white)
  - ja dominē sarkanā krāsa, jāizvada 'R' (red)
  - ja dominē zaļā krāsa, jāizvada 'G' (green)
  - ja dominē zilā krāsa, jāizvada 'B' (blue)
  - ja dominē zaļā un zilā krāsa, jāizvada 'C' (cyan)
  - ja dominē sarkanā un zilā krāsa, jāizvada 'M' (magenta)
  - ja dominē zaļā un sarkanā krāsa, jāizvada 'Y' (yellow) 