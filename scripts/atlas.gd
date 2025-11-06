extends CharacterBody2D

# === REFERÊNCIAS AOS NODES ===
@onready var animated_sprite = $AnimatedSprite2D
@onready var interaction_icon = $InteractionIcon
@onready var dialogue_ui = $CanvasLayer
@onready var dialogue_text = $CanvasLayer/Panel/MarginContainer/RichTextLabel

@export var dialogue_speed: float = 0.05
@export var interaction_key: String = "ui_accept"

var full_text: String = "Bem vindo a Horizon! Aqui você pode realizar os seus sonhos, ou seus Piores pesadelos, Muahahaha..."

# === VARIÁVEIS DE ESTADO ===
var player_nearby: bool = false
var dialogue_active: bool = false
var text_fully_displayed: bool = false
var current_char: int = 0
var timer: float = 0.0
var animation_triggered: bool = false

func _ready():
	dialogue_ui.visible = false
	interaction_icon.visible = false

func _process(delta):
	if dialogue_active and not text_fully_displayed:
		timer += delta
		if timer >= dialogue_speed:
			timer = 0.0
			current_char += 1
			dialogue_text.visible_characters = current_char
			
			# Detecta quando chegou no "Muahahaha" e toca animação
			if current_char >= 88 and not animation_triggered:
				animated_sprite.play("idle")
				animation_triggered = true
			
			if current_char >= full_text.length():
				text_fully_displayed = true
	
	if Input.is_action_just_pressed(interaction_key):
		if player_nearby and not dialogue_active:
			open_dialogue()
		elif dialogue_active:
			if text_fully_displayed:
				close_dialogue()
			else:
				skip_typewriter()

func open_dialogue():
	dialogue_active = true
	dialogue_ui.visible = true
	interaction_icon.visible = false
	dialogue_text.text = full_text
	dialogue_text.visible_characters = 0
	current_char = 0
	text_fully_displayed = false
	animation_triggered = false
	timer = 0.0

func close_dialogue():
	dialogue_active = false
	dialogue_ui.visible = false
	animated_sprite.stop()
	animated_sprite.frame = 0
	if player_nearby:
		interaction_icon.visible = true

func skip_typewriter():
	dialogue_text.visible_characters = full_text.length()
	current_char = full_text.length()
	text_fully_displayed = true
	# Garante que animação toca mesmo se pular
	if not animation_triggered:
		animated_sprite.play("idle")
		animation_triggered = true

func _on_area_proximidade_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		if not dialogue_active:
			interaction_icon.visible = true

func _on_area_proximidade_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		interaction_icon.visible = false
