module QuestModule
  
  # You don't actually need to add any information, but the respective fields in the UI will be blank or "???"
  # I included this here mostly as an example of what not to do, but also to show it's a thing that exists
  Quest0 = {
  
  }
  
  # Quête 1 - Village 1 (Village de Départ)
  Quest1 = {
    :ID => "1",
    :Name => "Le Serment de Freljord",
    :QuestGiver => "Professeur de Freljord",
    :Stage1 => "Choisissez votre premier compagnon au Laboratoire.",
    :Stage2 => "Traversez la Route 1 et battez Krag le Gardien des Portes.",
    :Stage3 => "Atteignez le refuge de Havre-Givré, village intermédiaire de montagne.",
    :Location1 => "Village de Départ",
    :Location2 => "Route 1",
    :Location3 => "Havre-Givré",
    :QuestDescription => "Choisissez votre starter au laboratoire du Village de Départ et commencez votre traversée des terres gelées vers le Nord.",
    :RewardString => "Sort d'Invocateur & Kit de Survie"
  }
  
  # Quête 2 - Havre-Givré (Village Intermédiaire)
  Quest2 = {
    :ID => "2",
    :Name => "La Halte de Havre-Givré",
    :QuestGiver => "Éclaireur Boréal",
    :Stage1 => "Réchauffez votre équipe près de l'âtre au Refuge de montagne.",
    :Stage2 => "Découvrez les étals du Marché et forgez un objet à l'Enclume LoL.",
    :Stage3 => "Consultez l'Éclaireur au pont Nord pour ouvrir la voie vers la Grande Ville.",
    :Location1 => "Havre-Givré",
    :Location2 => "Havre-Givré",
    :Location3 => "Havre-Givré",
    :QuestDescription => "Faites étape à Havre-Givré avant de gravir les hauts sommets : reposez votre équipe, découvrez la Forge d'artisanat et le Marché boréal.",
    :RewardString => "Accès à la Passe des Cimes"
  }
  
  # Quête 3 - Grande Ville de Freljord (La Grande Épreuve)
  Quest3 = {
    :ID => "3",
    :Name => "La Grande Épreuve des Cimes",
    :QuestGiver => "Matriarche de Freljord",
    :Stage1 => "Traversez la passe de montagne et pénétrez dans la Grande Ville.",
    :Stage2 => "Présentez-vous devant les Gardiens du Sanctuaire de l'Épreuve.",
    :Stage3 => "Triomphez du Gardien d'Épreuve (Master AI).",
    :Location1 => "Passe de Montagne",
    :Location2 => "Grande Ville de Freljord",
    :Location3 => "Sanctuaire de l'Épreuve",
    :QuestDescription => "Rendez-vous dans la Grande Ville de Freljord pour vous présenter au Sanctuaire et passer l'Épreuve tellurique ancestrale.",
    :RewardString => "Bénédiction Tellurique & Gloire d'Anivia"
  }
  
  # Here's an example of not defining the quest giver and reward text
  Quest4 = {
    :ID => "4",
    :Name => "A new beginning",
    :QuestGiver => "nil",
    :Stage1 => "Turning over a new leaf... literally!",
    :Stage2 => "Help your neighbours.",
    :Location1 => "Milky Way",
    :Location2 => "nil",
    :QuestDescription => "You crash landed on an alien planet. There are other humans here and they look hungry...",
    :RewardString => "nil"
  }
  
  # Other random examples you can look at if you want to fill out the UI and check out the page scrolling
  Quest5 = {
    :ID => "5",
    :Name => "All of my friends",
    :QuestGiver => "Barry",
    :Stage1 => "Meet your friends near Acuity Lake.",
    :QuestDescription => "Barry told me that he saw something cool at Acuity Lake and that I should go see. I hope it's not another trick.",
    :RewardString => "You win nothing for giving in to peer pressure."
  }
  
  Quest6 = {
    :ID => "6",
    :Name => "The journey begins",
    :QuestGiver => "Professor Oak",
    :Stage1 => "Deliver the parcel to the Pokémon Mart in Viridian City.",
    :Stage2 => "Return to the Professor.",
    :Location1 => "Viridian City",
    :Location2 => "nil",
    :QuestDescription => "The Professor has entrusted me with an important delivery for the Viridian City Pokémon Mart. This is my first task, best not mess it up!",
    :RewardString => "nil"
  }
  
  Quest7 = {
    :ID => "7",
    :Name => "Close encounters of the... first kind?",
    :QuestGiver => "nil",
    :Stage1 => "Make contact with the strange creatures.",
    :Location1 => "Rock Tunnel",
    :QuestDescription => "A sudden burst of light, and then...! What are you?",
    :RewardString => "A possible probing."
  }
  
  Quest8 = {
    :ID => "8",
    :Name => "These boots were made for walking",
    :QuestGiver => "Musician #1",
    :Stage1 => "Listen to the musician's, uhh, music.",
    :Stage2 => "Find the source of the power outage.",
    :Location1 => "nil",
    :Location2 => "Celadon City Sewers",
    :QuestDescription => "A musician was feeling down because he thinks no one likes his music. I should help him drum up some business."
  }
  
  Quest9 = {
    :ID => "9",
    :Name => "Got any grapes?",
    :QuestGiver => "Duck",
    :Stage1 => "Listen to The Duck Song.",
    :Stage2 => "Try not to sing it all day.",
    :Location1 => "YouTube",
    :QuestDescription => "Let's try to revive old memes by listening to this funny song about a duck wanting grapes.",
    :RewardString => "A loss of braincells. Hurray!"
  }
  
  Quest10 = {
    :ID => "10",
    :Name => "Singing in the rain",
    :QuestGiver => "Some old dude",
    :Stage1 => "I've run out of things to write.",
    :Stage2 => "If you're reading this, I hope you have a great day!",
    :Location1 => "Somewhere prone to rain?",
    :QuestDescription => "Whatever you want it to be.",
    :RewardString => "Wet clothes."
  }
  
  Quest11 = {
    :ID => "11",
    :Name => "When is this list going to end?",
    :QuestGiver => "Me",
    :Stage1 => "When IS this list going to end?",
    :Stage2 => "123",
    :Stage3 => "456",
    :Stage4 => "789",
    :QuestDescription => "I'm losing my sanity.",
    :RewardString => "nil"
  }
  
  Quest12 = {
    :ID => "12",
    :Name => "The laaast melon",
    :QuestGiver => "Some stupid dodo",
    :Stage1 => "Fight for the last of the food.",
    :Stage2 => "Don't die.",
    :Location1 => "A volcano/cliff thing?",
    :Location2 => "Good advice for life.",
    :QuestDescription => "Tea and biscuits, anyone?",
    :RewardString => "Food, glorious food!"
  }

end
