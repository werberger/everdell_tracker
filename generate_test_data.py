import json
import random
import uuid
from datetime import datetime, timedelta
from collections import defaultdict

# Base game card quantities (from card_details.txt)
CARD_QUANTITIES = {
    # Common cards (multiple copies)
    "farm": 8, "general_store": 3, "inn": 3, "mine": 3, "post_office": 3,
    "resin_refinery": 3, "storehouse": 3, "twig_barge": 3, "ruins": 3,
    "barge_toad": 3, "chip_sweep": 3, "husband": 4, "peddler": 3,
    "postal_pigeon": 3, "teacher": 3, "wife": 4, "wanderer": 3, "woodcarver": 3,
    # Unique cards (1 copy each)
    "architect": 1, "bard": 1, "castle": 1, "cemetery": 1, "chapel": 1,
    "clock_tower": 1, "courthouse": 1, "crane": 1, "doctor": 1, "dungeon": 1,
    "ever_tree": 1, "fairgrounds": 1, "fool": 1, "historian": 1, "innkeeper": 1,
    "judge": 1, "king": 1, "lookout": 1, "miner_mole": 1, "monastery": 1,
    "monk": 1, "palace": 1, "queen": 1, "ranger": 1, "school": 1,
    "shepherd": 1, "shopkeeper": 1, "theatre": 1, "undertaker": 1, "university": 1
}

# Base game card IDs
BASE_CARD_IDS = list(CARD_QUANTITIES.keys())

# Player names
PLAYERS = ["Alice", "Bob", "Charlie", "Diana", "Eve", "Frank", "Grace", "Henry"]

# Common ending city archetypes (realistic combinations based on Everdell strategies)
CITY_ARCHETYPES = [
    # Production-focused
    ["farm", "general_store", "mine", "resin_refinery", "twig_barge", "barge_toad", "chip_sweep", "peddler"],
    # Prosperity-focused
    ["castle", "ever_tree", "palace", "school", "theatre", "architect", "king", "wife"],
    # Governance-focused
    ["clock_tower", "courthouse", "crane", "dungeon", "university", "historian", "innkeeper", "judge"],
    # Destination-focused
    ["cemetery", "chapel", "inn", "lookout", "monastery", "post_office", "queen"],
    # Balanced
    ["farm", "castle", "school", "theatre", "historian", "shopkeeper", "teacher", "woodcarver"],
    # Small efficient
    ["ever_tree", "palace", "king", "architect", "wife", "husband"],
    # Production + Prosperity
    ["farm", "general_store", "castle", "palace", "school", "barge_toad", "chip_sweep", "wife"],
    # Governance + Destination
    ["clock_tower", "courthouse", "chapel", "inn", "historian", "judge", "queen"],
    # Critter-heavy
    ["architect", "king", "queen", "historian", "judge", "shopkeeper", "teacher", "woodcarver"],
    # Construction-heavy
    ["castle", "palace", "school", "theatre", "ever_tree", "fairgrounds", "university"],
]

def generate_city_cards(archetype, game_card_usage, max_cards=15):
    """Generate a realistic city from an archetype, respecting card quantities for this game"""
    cards = []
    used_counts = defaultdict(int)
    
    # Start with archetype cards
    for card_id in archetype:
        if card_id in BASE_CARD_IDS:
            # Check if we can use this card (considering all players in this game)
            total_used_in_game = game_card_usage[card_id] + used_counts[card_id]
            if total_used_in_game < CARD_QUANTITIES[card_id]:
                cards.append(card_id)
                used_counts[card_id] += 1
    
    # Fill to reasonable city size (8-15 cards)
    target_size = random.randint(8, min(max_cards, 15))
    attempts = 0
    while len(cards) < target_size and attempts < 50:
        card_id = random.choice(BASE_CARD_IDS)
        total_used_in_game = game_card_usage[card_id] + used_counts[card_id]
        if total_used_in_game < CARD_QUANTITIES[card_id]:
            cards.append(card_id)
            used_counts[card_id] += 1
        attempts += 1
    
    return cards, used_counts

def calculate_card_points(cards, card_data):
    """Calculate base points from cards"""
    total = 0
    for card_id in cards:
        card = next((c for c in card_data if c["id"] == card_id), None)
        if card:
            total += card.get("basePoints", 0)
    return total

def calculate_conditional_bonus(cards, basic_events, special_events):
    """Calculate conditional scoring bonuses"""
    bonus = 0
    
    # King: 1 VP per basic event + 2 VP per special event
    if "king" in cards:
        bonus += basic_events + special_events * 2
    
    # Architect: 1 VP per pebble/resin (max 6) - simplified
    if "architect" in cards:
        bonus += min(6, random.randint(0, 6))
    
    # Castle: 1 VP per common construction
    if "castle" in cards:
        common_constructions = ["farm", "general_store", "inn", "mine", "post_office", 
                               "resin_refinery", "storehouse", "twig_barge", "ruins"]
        bonus += len([c for c in cards if c in common_constructions])
    
    # Palace: 1 VP per unique construction
    if "palace" in cards:
        unique_constructions = ["castle", "cemetery", "chapel", "clock_tower", "courthouse", 
                               "crane", "dungeon", "ever_tree", "fairgrounds", "lookout", 
                               "monastery", "palace", "school", "theatre", "university"]
        bonus += len([c for c in cards if c in unique_constructions])
    
    # School: 1 VP per common critter
    if "school" in cards:
        common_critters = ["barge_toad", "chip_sweep", "husband", "peddler", "postal_pigeon", 
                          "teacher", "wife", "wanderer", "woodcarver"]
        bonus += len([c for c in cards if c in common_critters])
    
    # Theatre: 1 VP per unique critter
    if "theatre" in cards:
        unique_critters = ["architect", "bard", "doctor", "fool", "historian", "innkeeper", 
                          "judge", "king", "miner_mole", "monk", "queen", "ranger", 
                          "shepherd", "shopkeeper", "undertaker"]
        bonus += len([c for c in cards if c in unique_critters])
    
    # Wife/Husband pairing
    if "wife" in cards and "husband" in cards:
        bonus += 3
    
    # Ever Tree: 1 VP per prosperity card
    if "ever_tree" in cards:
        prosperity_cards = ["castle", "ever_tree", "palace", "school", "theatre", 
                           "architect", "king", "wife"]
        bonus += len([c for c in cards if c in prosperity_cards])
    
    return bonus

def generate_player_score(player_name, player_id, entry_type, card_data, game_card_usage):
    """Generate a player score based on entry type"""
    # Determine score range
    base_score = random.randint(25, 85)
    score = base_score + random.randint(-5, 15)
    score = max(20, min(100, score))
    
    if entry_type == "quick":
        # Quick entry: just total score
        return {
            "playerId": player_id,
            "playerName": player_name,
            "totalScore": score,
            "tiebreakerResources": random.randint(0, 10),
            "isWinner": False,
            "isQuickEntry": True
        }
    
    elif entry_type == "basic":
        # Basic input: breakdown by category
        card_points = random.randint(15, 50)
        point_tokens = random.randint(0, 8)
        basic_events = random.randint(0, 3)
        special_events = random.randint(0, 2)
        journey_points = random.randint(0, 6)
        prosperity_points = random.randint(2, 15)
        
        # Calculate breakdowns
        construction_points = random.randint(5, 25)
        critter_points = random.randint(5, 25)
        production_points = random.randint(2, 15)
        destination_points = random.randint(2, 12)
        governance_points = random.randint(2, 12)
        traveller_points = random.randint(0, 8)
        
        total_calc = (card_points + point_tokens + basic_events * 2 + 
                     special_events * 3 + journey_points + prosperity_points)
        
        # Adjust to match target score
        if total_calc != score:
            diff = score - total_calc
            card_points = max(15, card_points + diff)
        
        return {
            "playerId": player_id,
            "playerName": player_name,
            "pointTokens": point_tokens,
            "cardPoints": card_points,
            "basicEvents": basic_events,
            "specialEvents": special_events,
            "journeyPoints": journey_points,
            "prosperityPoints": prosperity_points,
            "constructionPoints": construction_points,
            "critterPoints": critter_points,
            "productionPoints": production_points,
            "destinationPoints": destination_points,
            "governancePoints": governance_points,
            "travellerPoints": traveller_points,
            "prosperityCardPoints": prosperity_points,
            "totalScore": score,
            "tiebreakerResources": random.randint(0, 10),
            "isWinner": False,
            "isQuickEntry": False,
            "leftoverBerries": random.randint(0, 3),
            "leftoverResin": random.randint(0, 3),
            "leftoverPebbles": random.randint(0, 3),
            "leftoverWood": random.randint(0, 3)
        }
    
    else:  # visual
        # Visual card selection: actual card IDs
        archetype = random.choice(CITY_ARCHETYPES)
        cards, used_counts = generate_city_cards(archetype, game_card_usage)
        
        # Update game card usage
        for card_id, count in used_counts.items():
            game_card_usage[card_id] += count
        
        # Calculate points
        base_card_points = calculate_card_points(cards, card_data)
        point_tokens = random.randint(0, 8)
        basic_events = random.randint(0, 3)
        special_events = random.randint(0, 2)
        journey_points = random.randint(0, 6)
        
        # Add conditional scoring bonuses
        bonus = calculate_conditional_bonus(cards, basic_events, special_events)
        
        total_score = base_card_points + point_tokens + basic_events * 2 + special_events * 3 + journey_points + bonus
        
        # Adjust to target range
        if total_score < 20:
            total_score = 20 + random.randint(0, 10)
        elif total_score > 100:
            total_score = 100 - random.randint(0, 10)
        
        # Token counts for conditional scoring
        card_token_counts = {}
        if "clock_tower" in cards:
            card_token_counts["clock_tower"] = random.randint(0, 3)
        if "chapel" in cards:
            card_token_counts["chapel"] = random.randint(0, 5)
        
        # Resource counts for Architect
        card_resource_counts = {}
        if "architect" in cards:
            card_resource_counts["architect"] = random.randint(0, 6)
        
        return {
            "playerId": player_id,
            "playerName": player_name,
            "selectedCardIds": cards,
            "cardTokenCounts": card_token_counts if card_token_counts else None,
            "cardResourceCounts": card_resource_counts if card_resource_counts else None,
            "pointTokens": point_tokens,
            "cardPoints": base_card_points,
            "basicEvents": basic_events,
            "specialEvents": special_events,
            "journeyPoints": journey_points,
            "totalScore": total_score,
            "tiebreakerResources": random.randint(0, 10),
            "isWinner": False,
            "isQuickEntry": False,
            "leftoverBerries": random.randint(0, 3),
            "leftoverResin": random.randint(0, 3),
            "leftoverPebbles": random.randint(0, 3),
            "leftoverWood": random.randint(0, 3)
        }

def main():
    # Load card data
    with open("assets/cards_data.json", "r", encoding="utf-8") as f:
        card_data = json.load(f)
    
    base_cards = [c for c in card_data if c.get("module") == "base"]
    
    # Generate games
    games = []
    
    # Entry type distribution: 5 quick, 30 basic, 65 visual
    entry_types = ["quick"] * 5 + ["basic"] * 30 + ["visual"] * 65
    random.shuffle(entry_types)
    
    start_date = datetime.now() - timedelta(days=365)
    
    for game_num in range(100):
        # Player count: 2-6, mostly 2-4
        if random.random() < 0.7:
            num_players = random.randint(2, 4)
        else:
            num_players = random.randint(2, 6)
        
        # Select players
        selected_players = random.sample(PLAYERS, num_players)
        
        # Entry type for this game (all players use same type)
        entry_type = entry_types[game_num]
        
        # Track card usage for this game (per game, not global)
        game_card_usage = defaultdict(int)
        
        # Generate player scores
        players = []
        scores = []
        
        for i, player_name in enumerate(selected_players):
            player_id = f"player_{game_num}_{i}"
            score_data = generate_player_score(
                player_name, player_id, entry_type, 
                base_cards, game_card_usage
            )
            players.append(score_data)
            scores.append(score_data["totalScore"])
        
        # Determine winner(s)
        max_score = max(scores)
        winner_ids = [p["playerId"] for p in players if p["totalScore"] == max_score]
        for player in players:
            player["isWinner"] = player["playerId"] in winner_ids
        
        # Create game
        game_date = start_date + timedelta(days=game_num * 3 + random.randint(0, 2))
        game = {
            "id": str(uuid.uuid4()),
            "dateTime": game_date.isoformat(),
            "expansionsUsed": [],  # Base game only
            "players": players,
            "notes": None,
            "winnerIds": winner_ids
        }
        
        games.append(game)
    
    # Create export format
    export_data = {
        "version": "2.1.0",
        "exportDate": datetime.now().isoformat(),
        "games": games,
        "playerNames": PLAYERS
    }
    
    # Write to file
    with open("test_data_100_games.json", "w", encoding="utf-8") as f:
        json.dump(export_data, f, indent=2)
    
    print(f"Generated {len(games)} games")
    quick_count = sum(1 for g in games if any(p.get('isQuickEntry') for p in g['players']))
    basic_count = sum(1 for g in games if not any(p.get('isQuickEntry') for p in g['players']) 
                     and not any(p.get('selectedCardIds') for p in g['players']))
    visual_count = sum(1 for g in games if any(p.get('selectedCardIds') for p in g['players']))
    print(f"Quick entry: {quick_count}")
    print(f"Basic input: {basic_count}")
    print(f"Visual selection: {visual_count}")

if __name__ == "__main__":
    main()
