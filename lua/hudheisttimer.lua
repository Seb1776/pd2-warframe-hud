Hooks:PostHook(HUDHeistTimer, "init", "init_wfhud", function (self)
	self._heist_timer_panel:set_visible(false)
end)

Hooks:OverrideFunction(HUDHeistTimer, "set_time", function (self, time)
	WFHud._objective_panel:set_time(time)
end)
