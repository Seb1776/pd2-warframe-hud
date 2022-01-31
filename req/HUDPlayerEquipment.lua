HUDPlayerEquipment = class()

function HUDPlayerEquipment:init(panel)
	self._panel = panel:panel({
		w = 600
	})

	self._bag_icon = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = { 2, 34, 20, 17 },
		color = WFHud.colors.default,
		x = self._panel:w() - 20,
		w = 20,
		h = 17
	})

	self._bag_text = self._panel:text({
		visible = false,
		text = "THERMAL DRILL",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
	})

	self:_align_bag_text()

	self._ammo_text = self._panel:text({
		color = WFHud.colors.default,
		text = "30",
		font = WFHud.fonts.large,
		font_size = WFHud.font_sizes.huge,
		y = self._bag_icon:bottom() + 32
	})

	self._total_ammo_text = self._panel:text({
		color = WFHud.colors.default,
		text = "/ 120",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default,
		y = self._ammo_text:y()
	})

	self:_align_ammo_text()

	self._weapon_name = self._panel:text({
		color = WFHud.colors.default,
		text = "AMCAR RIFLE",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small,
		y = self._total_ammo_text:bottom()
	})

	self._fire_mode_text = self._panel:text({
		color = WFHud.colors.muted,
		text = "AUTO",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small,
		y = self._total_ammo_text:bottom()
	})

	self:_align_weapon_text()

	self._equipment_list = HUDIconList:new(self._panel, 0, self._fire_mode_text:bottom() + 2, 24, 24, WFHud.colors.default)
	self._item_list = HUDIconList:new(self._panel, 0, self._fire_mode_text:bottom() + 2, self._panel:w(), 24, WFHud.colors.default)

	self:_align_equipment()

	self._stamina_panel = self._panel:panel({
		x = self._panel:w() - 128,
		y = self._item_list._panel:bottom() + 4,
		w = 128,
		h = 5
	})

	self._stamina_bar_bg = self._stamina_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.bg:with_alpha(0.5),
		w = self._stamina_panel:w(),
		h = self._stamina_panel:h(),
		layer = -1
	})

	self._stamina_bar = self._stamina_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.default,
		w = self._stamina_panel:w(),
		h = self._stamina_panel:h()
	})

	self._stamina_text = self._panel:text({
		color = WFHud.colors.default,
		text = "50",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.small,
		align = "right",
		y = self._stamina_panel:bottom()
	})

	self._stamina_ratio = 1

	self._panel:set_h(self._stamina_panel:bottom() + self._stamina_text:font_size())
	self._panel:set_rightbottom(panel:w() - WFHud.MARGIN_H, panel:h() - WFHud.MARGIN_V)
end

function HUDPlayerEquipment:_align_bag_text()
	local _, _, w, h = self._bag_text:text_rect()
	self._bag_text:set_size(w, h)
	self._bag_text:set_right(self._bag_icon:x() - 8)
	self._bag_text:set_center_y(self._bag_icon:center_y())
end

function HUDPlayerEquipment:_align_ammo_text()
	local _, _, w, h = self._ammo_text:text_rect()
	self._ammo_text:set_size(w, h)

	local _, _, w, h = self._total_ammo_text:text_rect()
	self._total_ammo_text:set_size(w, h)

	self._total_ammo_text:set_rightbottom(self._panel:w(), self._ammo_text:y() + self._ammo_text:h())
	self._ammo_text:set_right(self._total_ammo_text:x() - self._total_ammo_text:h() * 0.25)
end

function HUDPlayerEquipment:_align_weapon_text()
	local _, _, w, h = self._weapon_name:text_rect()
	self._weapon_name:set_size(w, h)

	local _, _, w, h = self._fire_mode_text:text_rect()
	self._fire_mode_text:set_size(w, h)

	self._fire_mode_text:set_right(self._panel:w())
	self._weapon_name:set_right(self._fire_mode_text:x() - self._fire_mode_text:h() * 0.25)
end

function HUDPlayerEquipment:_align_equipment()
	self._equipment_list._panel:set_w((self._equipment_list._size + self._equipment_list._spacing) * #self._equipment_list._panel:children())
	self._equipment_list:_layout_panel()
	self._equipment_list._panel:set_right(self._panel:w())
	self._item_list._panel:set_right(self._equipment_list._panel:x())
end

function HUDPlayerEquipment:set_bag(bag_text)
	if bag_text then
		self._bag_icon:set_visible(true)
		self._bag_text:set_text(bag_text)
		self._bag_text:set_visible(true)
		self:_align_bag_text()
	else
		self._bag_icon:set_visible(false)
		self._bag_text:set_visible(false)
	end
end

function HUDPlayerEquipment:set_ammo(wbase)
	local mag_max, mag, total = wbase:ammo_info()
	if mag_max <= 1 then
		self._ammo_text:set_text(tostring(total))
		self._ammo_text:set_alpha(mag < 1 and 0.5 or 1)
		self._total_ammo_text:set_text("   ")
	else
		self._ammo_text:set_text(tostring(mag))
		self._ammo_text:set_alpha(1)
		self._total_ammo_text:set_text(string.format("/ %u", total - mag))
	end

	self:_align_ammo_text()
end

function HUDPlayerEquipment:set_fire_mode(wbase)
	local gadget_base = wbase:gadget_overrides_weapon_functions()
	local fire_mode_text
	if HopLib:is_object_of_class(gadget_base, WeaponUnderbarrel) then
		fire_mode_text = managers.localization:to_upper_text("hud_fire_mode_" .. gadget_base.GADGET_TYPE)
	elseif wbase:can_toggle_firemode() then
		fire_mode_text = managers.localization:to_upper_text("hud_fire_mode_" .. wbase:fire_mode())
	end
	self._fire_mode_text:set_text(fire_mode_text or "")
	self:_align_weapon_text()
end

function HUDPlayerEquipment:set_weapon(wbase)
	local tweak = tweak_data.weapon[wbase._name_id]

	self._weapon_name:set_text(managers.localization:to_upper_text(tweak.name_id))

	self:set_fire_mode(wbase)
	self:set_ammo(wbase)
end

function HUDPlayerEquipment:set_stamina(current, total, instant)
	if not current or not total then
		return
	end

	local ratio = math.min(current / total, 1)

	if instant then
		self._stamina_ratio = ratio
		self._stamina_bar:set_w(self._stamina_bar_bg:w() * ratio)
		self._stamina_text:set_text(tostring(math.round(current)))
	else
		local start = self._stamina_ratio
		self._stamina_bar:stop()
		self._stamina_bar:animate(function (o)
			over(math.abs(start - ratio), function (t)
				self:set_stamina(math.lerp(start, ratio, t) * total, total, true)
			end)
		end)
	end
end
