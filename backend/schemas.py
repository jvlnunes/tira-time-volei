from pydantic import BaseModel
from datetime import datetime
from typing   import List, Optional
from enum     import Enum

class Position(str, Enum):
    LEVANTADOR = "Levantador"
    PONTEIRO   = "Ponteiro"
    OPOSTO     = "Oposto"
    LIBERO     = "Líbero"
    QUALQUER   = "Qualquer"
    
class PlayerBase(BaseModel):
    id: int
    name: str
    main_position: Position
    secondary_position: Optional[Position] = None
    rating: float = 0.0
    
class PlayerCreate(PlayerBase):
    pass

class Player(PlayerBase):
    id: int
    is_active: bool = True
    
    class Config:
        from_attributes = True
        
class Team(BaseModel):
    name: str 
    players: List[Player]
    has_special = False
    avg_rating: float
    
class MatchStats(BaseModel):
    match_date: datetime
    teams: List[Team]
    winner: Optional[Team] = None
    best_player: Optional[Player] = None
    score: str 
    substitutes = List[Player]
    polemic_count: int = 0
    
    