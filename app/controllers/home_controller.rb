class HomeController < ApplicationController
  def index
    # Provide sample games for display if none are assigned upstream
    @games ||= sample_games
  end

  private

  def sample_games
    now = Time.zone.now
    [
      {
        id: 1,
        home_team: "Arsenal",
        away_team: "Chelsea",
        league: "Premier League",
        kickoff_at: now + 2.hours,
        status: "Scheduled",
        home_score: nil,
        away_score: nil,
        venue: "Emirates Stadium"
      },
      {
        id: 2,
        home_team: "Barcelona",
        away_team: "Real Madrid",
        league: "La Liga",
        kickoff_at: now - 30.minutes,
        status: "Live",
        home_score: 1,
        away_score: 0,
        venue: "Camp Nou"
      },
      {
        id: 3,
        home_team: "Bayern",
        away_team: "Dortmund",
        league: "Bundesliga",
        kickoff_at: now - 2.days,
        status: "FT",
        home_score: 2,
        away_score: 2,
        venue: "Allianz Arena"
      }
    ]
  end
end
