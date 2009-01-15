Sąvybė: Sudėtis
  Norint išvengti kvailų klaidų
  Kaip matematinis idiotas
  Aš noriu, kad man pasakytų dviejų skaičių sumą

  # Someone please translate this in languages.yml please
  Scenario Outline: dviejų skaičių sudėtis
    Duota aš įvedžiau <įvestis_1> į skaičiuotuvą
    Ir aš įvedžiau <įvestis_2> į skaičiuotuvą
    Kai aš paspaudžiu "<mygtukas>"
    Tada rezultatas ekrane turi būti <išvestis>

  Pavyzdžių
    | įvestis_1 | įvestis_2 | mygtukas | išvestis |
    | 20        | 30        | add      | 50       |
    | 2         | 5         | add      | 7        |
    | 0         | 40        | add      | 40       |
