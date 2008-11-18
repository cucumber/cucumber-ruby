Fonction: Addition
  Afin d'eviter des conneries
  Etant un comptable
  Je désire additionner deux chiffres

  Scenario: 7 et 5
    Soit que j'ai entré 5
    Et que j'ai entré 7
    
  Scenario: Additionner
    SoitScenario: 7 et 5
    Lorsque je tape additionner
    Alors le reultat doit être 12
