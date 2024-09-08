--- STEAMODDED HEADER
--- MOD_NAME: Art Fight 2024
--- MOD_ID: AF2024
--- PREFIX: AF24
--- MOD_AUTHOR: [UltraCboy]
--- MOD_DESCRIPTION: Art Fight 2024
--- LOADER_VERSION_GEQ: 1.0.0
--- BADGE_COLOUR: 877FEB

----------------------------------------------
------------MOD CODE -------------------------


-- MAD
SMODS.Atlas{
    key = "afmad",
    path = "afmad.png",
    px = 71,
    py = 95
}

function count_editions(context)
	local c = 0
	for i = 1, #G.jokers.cards do
		local edition = G.jokers.cards[i]:get_edition(context)
		if edition then
			c = c + 1
		end
	end
	return c
end

SMODS.Joker{
    key = "afmad",
    name = "Mad",
    rarity = 4,
    discovered = true,
	blueprint_compat = true,
	perishable_compat = false,
	eternal_compat = true,
    pos = {x = 0, y = 0},
	soul_pos = {x = 1, y = 0},
    cost = 20,
    config = {
		extra = {wheel_used = false}
	},
    loc_txt = {
        name = "Mad",
        text = {
            "Creates a {C:dark_edition}Negative{} {C:attention}Wheel of Fortune{}",
			"card whenever a used {C:attention}Wheel of Fortune{}",
			"card fails to add an edition"
        }
    },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS['e_negative']
		info_queue[#info_queue+1] = G.P_CENTERS['c_wheel_of_fortune']
        return {vars = {}}
	end,
	calculate = function(self, card, context)
		if self.debuff then return nil end
		if context.using_consumeable and context.consumeable.ability.name == "The Wheel of Fortune" then
			local starting_editions = count_editions(context)
			G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.5, func = function()
				if count_editions(context) <= starting_editions then
					-- Create Card
					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
					G.E_MANAGER:add_event(Event({
						trigger = 'before',
						delay = 0.0,
						func = (function()
							local card = create_card('Tarot', G.consumeables, nil, nil, nil, nil, 'c_wheel_of_fortune', 'afmad')
							card:set_edition({negative = true}, true)
							card:add_to_deck()
							G.consumeables:emplace(card)
							G.GAME.consumeable_buffer = 0
							return true
						end)}))
					-- Message
					card_eval_status_text(card, 'extra', nil, nil, nil, {
						message = "Try Again!"
					})
				end
				return true
			end}))
		end
	end,
    atlas = "afmad"
}

-- DOTTY
SMODS.Atlas{
    key = "afdotty",
    path = "afdotty.png",
    px = 71,
    py = 95
}

function random_tarot_name()
	local tarots = {
		"The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
		"The Hierophant", "The Lovers", "The Chariot", "Justice", "The Hermit",
		"The Wheel of Fortune", "Strength", "The Hanged Man", "Death", "Temperance",
		"The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World",
	}
	return pseudorandom_element(tarots, pseudoseed('afdotty'))
end

SMODS.Joker{
    key = "afdotty",
    name = "Dotty",
    rarity = 4,
    discovered = true,
	blueprint_compat = true,
	perishable_compat = false,
	eternal_compat = true,
    pos = {x = 0, y = 0},
	soul_pos = {x = 1, y = 0},
    cost = 20,
    config = {
		extra = {
			increment = 0.25, current = 1, tarot = 'The Wheel of Fortune'
		}
	},
    loc_txt = {
        name = "Dotty",
        text = {
            "Gains {X:mult,C:white}X#1#{} Mult whenever",
			"a {C:attention}#2#{} card is used{}",
			"{s:0.8}Card changes when matching card is used{}",
			"{C:inactive}(Currently {X:mult,C:white}X#3#{C:inactive} Mult){}"
        }
    },
	loc_vars = function(self, info_queue, card)
        return {vars = {
			card.ability.extra.increment, 
			card.ability.extra.tarot,
			card.ability.extra.current
		}}
	end,
	calculate = function(self, card, context)
		if self.debuff then return nil end
		if context.using_consumeable and not context.blueprint then
			-- Scaling
			if context.consumeable.ability.name == card.ability.extra.tarot then
				card.ability.extra.current = card.ability.extra.current + card.ability.extra.increment
				card_eval_status_text(card, 'extra', nil, nil, nil, 
					{message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.extra.current}}}
				)
				card.ability.extra.tarot = random_tarot_name()
			end
		end
		if context.cardarea == G.jokers then
			-- Scoring
			if context.joker_main then
				if card.ability.extra.current > 1 then
					return {
						Xmult_mod = card.ability.extra.current,
						message = localize {
							type = 'variable',
							key = 'a_xmult',
							vars = {card.ability.extra.current}
						},
					}
				end
			end
		end
	end,
    atlas = "afdotty"
}

-- ??????
SMODS.Atlas{
    key = "afquestion",
    path = "afquestion.png",
    px = 71,
    py = 95
}

--function format_suit(suit)
--	if suit == "Spades" then return "spades" end
--	if suit == "Hearts" then return "hearts" end
--	if suit == "Diamonds" then return "diamonds" end
--	if suit == "Clubs" then return "clubs" end
--	if suit == "Wild" then return "attention" end
--	if suit == "Stone" then return "attention" end
--	return ""
--end

SMODS.Joker{
    key = "afquestion",
    name = "??????",
    rarity = 4,
    discovered = true,
	blueprint_compat = true,
	perishable_compat = false,
	eternal_compat = true,
    pos = {x = 0, y = 0},
	soul_pos = {x = 1, y = 0},
    cost = 20,
    config = {
		extra = {
			mult = 2, suit = "None"
		}
	},
    loc_txt = {
        name = "??????",
        text = {
            "Played cards with a different suit from",
			"the last scoring card each give",
			"{X:mult,C:white}X#1#{} Mult when scored",
			"{s:0.8,C:attention}Wild Cards{s:0.8} and {s:0.8,C:attention}Stone Cards{s:0.8} count as their own suits{}",
			"{C:inactive}(Currently {C:attention}#2#{C:inactive}){}"
        }
    },
	loc_vars = function(self, info_queue, card)
		info_queue[#info_queue+1] = G.P_CENTERS['m_wild']
		info_queue[#info_queue+1] = G.P_CENTERS['m_stone']
        return {vars = { 
			card.ability.extra.mult,
			card.ability.extra.suit,
		}}
	end,
	calculate = function(self, card, context)
		if self.debuff then return nil end
		if context.individual and context.cardarea == G.play and not context.other_card.debuff then
			local suit = context.other_card.base.suit
			if context.other_card.ability.name == "Stone Card" then suit = "Stone" end
			if context.other_card.ability.name == "Wild Card" then suit = "Wild" end
			if suit ~= card.ability.extra.suit then
				card.ability.extra.suit = suit
				return {
					x_mult = card.ability.extra.mult,
					colour = G.C.RED,
					card = card
				}
			end
		end
	end,
    atlas = "afquestion"
}

-- Deck
SMODS.Atlas{
    key = "deck",
    path = "deck.png",
    px = 71,
    py = 95
}

local afjokers = {
	"j_AF24_afmad", "j_AF24_afdotty", "j_AF24_afquestion"
}

local old_apply_to_run = Back.apply_to_run
Back.apply_to_run = function(self)
	local ret = old_apply_to_run(self)
	if self.name == "Seafoam and Stardust" then
		G.GAME.joker_buffer = G.GAME.joker_buffer + 1
        G.E_MANAGER:add_event(Event({
            func = function()
				-- Create Joker
				local foo = pseudorandom_element(afjokers, pseudoseed('afdeck'))
                local card = create_card('Joker', G.jokers, nil, nil, nil, nil, foo, 'afdeck')
                card:add_to_deck()
                G.jokers:emplace(card)
                card:start_materialize()
                G.GAME.joker_buffer = 0
                return true
            end}))
	end
	return ret
end

SMODS.Back{
	name = "Seafoam and Stardust",
	key = "afdeck",
	pos = {x = 0, y = 0},
	config = {},
	loc_txt = {
		name = "Seafoam and Stardust",
		text = {
			"Start with a random {C:legendary,E:1}Legendary{}",
			"{C:dark_edition}Art Fight 2024{} Joker"
		},
    },
	apply = function(back)
		--G.GAME.joker_buffer = G.GAME.joker_buffer + 1
        --G.E_MANAGER:add_event(Event({
        --    func = function()
		--		-- Create Joker
		--		local foo = pseudorandom_element(afjokers, "afdeck")
        --        local card = create_card('Joker', G.jokers, nil, nil, nil, nil, foo, 'afdeck')
        --        card:add_to_deck()
        --        G.jokers:emplace(card)
        --        card:start_materialize()
        --        G.GAME.joker_buffer = 0
        --        return true
        --    end}))
	end,
	atlas = "deck"
}

----------------------------------------------
------------MOD CODE END----------------------