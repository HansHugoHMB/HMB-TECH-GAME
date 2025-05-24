defmodule WordGameWeb.GameLive do
  use WordGameWeb, :live_view
  
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, 
      game_state: %{
        players: %{},
        current_player: nil,
        words: %{},
        guessed_letters: %{},
        current_turn: nil,
        winner: nil
      }
    )}
  end

  @impl true
  def handle_event("join_game", %{"game_code" => code, "player_name" => name}, socket) do
    game_state = socket.assigns.game_state
    
    if map_size(game_state.players) >= 2 && !Map.has_key?(game_state.players, name) do
      {:noreply, put_flash(socket, :error, "La partie est complète")}
    else
      updated_game = update_in(game_state.players, &Map.put(&1, name, %{id: map_size(&1) + 1}))
      updated_game = %{updated_game | current_player: name}
      
      {:noreply, assign(socket, game_state: updated_game)}
    end
  end

  @impl true
  def handle_event("submit_word", %{"word" => word}, socket) do
    game_state = socket.assigns.game_state
    current_player = game_state.current_player
    
    updated_game = put_in(game_state.words[current_player], String.downcase(word))
    
    updated_game = if map_size(updated_game.words) == 2 do
      %{updated_game |
        current_turn: hd(Map.keys(updated_game.players)),
        guessed_letters: Map.new(updated_game.players, fn {player, _} -> {player, []} end)
      }
    else
      updated_game
    end
    
    {:noreply, assign(socket, game_state: updated_game)}
  end

  @impl true
  def handle_event("guess_letter", %{"letter" => letter}, socket) do
    game_state = socket.assigns.game_state
    current_player = game_state.current_player
    
    if game_state.current_turn != current_player do
      {:noreply, put_flash(socket, :error, "Ce n'est pas votre tour")}
    else
      opponent = Enum.find(Map.keys(game_state.players), &(&1 != current_player))
      opponent_word = game_state.words[opponent]
      
      updated_game = update_in(
        game_state.guessed_letters[current_player],
        &[letter | &1]
      )
      
      updated_game = if String.contains?(opponent_word, letter) do
        updated_game
      else
        %{updated_game | current_turn: opponent}
      end
      
      # Vérifier la victoire
      updated_game = if word_guessed?(opponent_word, updated_game.guessed_letters[current_player]) do
        %{updated_game | winner: current_player}
      else
        updated_game
      end
      
      {:noreply, assign(socket, game_state: updated_game)}
    end
  end

  @impl true
  def handle_event("reset_game", _params, socket) do
    {:noreply, assign(socket, game_state: %{
      players: %{},
      current_player: nil,
      words: %{},
      guessed_letters: %{},
      current_turn: nil,
      winner: nil
    })}
  end

  defp word_guessed?(word, guessed_letters) do
    String.graphemes(word)
    |> Enum.all?(&(&1 in guessed_letters))
  end
end