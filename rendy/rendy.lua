--------------------------------------------------------------------------------
-- License
--------------------------------------------------------------------------------

-- Copyright (c) 2024 Klayton Kowalski

-- This software is provided 'as-is', without any express or implied warranty.
-- In no event will the authors be held liable for any damages arising from the use of this software.

-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it freely,
-- subject to the following restrictions:

-- 1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--    If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.

-- 2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.

-- 3. This notice may not be removed or altered from any source distribution.

--------------------------------------------------------------------------------
-- Information
--------------------------------------------------------------------------------

-- GitHub: https://github.com/klaytonkowalski/library-defold-rendy

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local message_acquire_camera_focus = hash("acquire_camera_focus")
local message_release_camera_focus = hash("release_camera_focus")

--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------

local rendy = {}

rendy.cameras = {}

rendy.window_width = nil
rendy.window_height = nil

local function is_within_viewport(camera, screen_x, screen_y)
	return
		camera.viewport_px <= screen_x and
		screen_x <= camera.viewport_px + camera.viewport_pw and
		camera.viewport_py <= screen_y and
		screen_y <= camera.viewport_py + camera.viewport_ph
end

--------------------------------------------------------------------------------
-- Module Functions
--------------------------------------------------------------------------------

function rendy.create_camera(id)
	if rendy.cameras[id] then
		print("Defold Rendy: rendy.create_camera() -> Camera already exists: " .. id)
		return
	end
	local camera_url = msg.url(nil, id, "camera")
	local script_url = msg.url(nil, id, "script")
	local viewport_px = 0
	local viewport_py = 0
	local viewport_pw = 0
	local viewport_ph = 0
	local view_transform = vmath.matrix4()
	local projection_transform = vmath.matrix4()
	local frustum = vmath.matrix4()
	local active = go.get(script_url, "active")
	local orthographic = go.get(script_url, "orthographic")
	local resize_mode_center = go.get(script_url, "resize_mode_center")
	local resize_mode_expand = go.get(script_url, "resize_mode_expand")
	local resize_mode_stretch = go.get(script_url, "resize_mode_stretch")
	local viewport_x = go.get(script_url, "viewport_x")
	local viewport_y = go.get(script_url, "viewport_y")
	local viewport_width = go.get(script_url, "viewport_width")
	local viewport_height = go.get(script_url, "viewport_height")
	local z_min = go.get(script_url, "z_min")
	local z_max = go.get(script_url, "z_max")
	local resolution_width = go.get(script_url, "resolution_width")
	local resolution_height = go.get(script_url, "resolution_height")
	local zoom = go.get(script_url, "zoom")
	local field_of_view = go.get(script_url, "field_of_view")
	rendy.cameras[id] =
	{
		camera_url = camera_url,
		script_url = script_url,
		viewport_px = viewport_px,
		viewport_py = viewport_py,
		viewport_pw = viewport_pw,
		viewport_ph = viewport_ph,
		view_transform = view_transform,
		projection_transform = projection_transform,
		frustum = frustum,
		special = special,
		active = active,
		orthographic = orthographic,
		resize_mode_center = resize_mode_center,
		resize_mode_expand = resize_mode_expand,
		resize_mode_stretch = resize_mode_stretch,
		viewport_x = viewport_x,
		viewport_y = viewport_y,
		viewport_width = viewport_width,
		viewport_height = viewport_height,
		z_min = z_min,
		z_max = z_max,
		resolution_width = resolution_width,
		resolution_height = resolution_height,
		zoom = zoom,
		field_of_view = field_of_view
	}
	msg.post(camera_url, message_acquire_camera_focus)
end

function rendy.destroy_camera(id)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.destroy_camera() -> Camera does not exist: " .. id)
		return
	end
	msg.post(rendy.cameras[id].camera_url, message_release_camera_focus)
	rendy.cameras[id] = nil
end

function rendy.set_camera_active(id, flag)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_active() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "active", flag)
	rendy.cameras[id].active = flag
end

function rendy.set_camera_orthographic(id, flag)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_orthographic() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "orthographic", flag)
	rendy.cameras[id].orthographic = flag
end

function rendy.set_camera_resize_mode_center(id)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_resize_mode_center() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "resize_mode_center", true)
	go.set(rendy.cameras[id].script_url, "resize_mode_expand", false)
	go.set(rendy.cameras[id].script_url, "resize_mode_stretch", false)
	rendy.cameras[id].resize_mode_center = true
	rendy.cameras[id].resize_mode_expand = false
	rendy.cameras[id].resize_mode_stretch = false
end

function rendy.set_camera_resize_mode_expand(id)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_resize_mode_expand() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "resize_mode_center", false)
	go.set(rendy.cameras[id].script_url, "resize_mode_expand", true)
	go.set(rendy.cameras[id].script_url, "resize_mode_stretch", false)
	rendy.cameras[id].resize_mode_center = false
	rendy.cameras[id].resize_mode_expand = true
	rendy.cameras[id].resize_mode_stretch = false
end

function rendy.set_camera_resize_mode_stretch(id)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_resize_mode_stretch() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "resize_mode_center", false)
	go.set(rendy.cameras[id].script_url, "resize_mode_expand", false)
	go.set(rendy.cameras[id].script_url, "resize_mode_stretch", true)
	rendy.cameras[id].resize_mode_center = false
	rendy.cameras[id].resize_mode_expand = false
	rendy.cameras[id].resize_mode_stretch = true
end

function rendy.set_camera_viewport(id, x, y, width, height)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_viewport() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "viewport_x", x)
	go.set(rendy.cameras[id].script_url, "viewport_y", y)
	go.set(rendy.cameras[id].script_url, "viewport_width", width)
	go.set(rendy.cameras[id].script_url, "viewport_height", height)
	rendy.cameras[id].viewport_x = viewport_x
	rendy.cameras[id].viewport_y = viewport_y
	rendy.cameras[id].viewport_width = viewport_width
	rendy.cameras[id].viewport_height = viewport_height
end

function rendy.set_camera_range(id, z_min, z_max)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_range() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "z_min", z_min)
	go.set(rendy.cameras[id].script_url, "z_max", z_max)
	rendy.cameras[id].z_min = z_min
	rendy.cameras[id].z_max = z_max
end

function rendy.set_camera_resolution(id, width, height)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_resolution() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "resolution_width", width)
	go.set(rendy.cameras[id].script_url, "resolution_height", height)
	rendy.cameras[id].resolution_width = width
	rendy.cameras[id].resolution_height = height
end

function rendy.set_camera_zoom(id, zoom)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_zoom() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "zoom", zoom)
	rendy.cameras[id].zoom = zoom
end

function rendy.set_camera_field_of_view(id, field_of_view)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.set_camera_field_of_view() -> Camera does not exist: " .. id)
		return
	end
	go.set(rendy.cameras[id].script_url, "field_of_view", field_of_view)
	rendy.cameras[id].field_of_view = field_of_view
end

function rendy.screen_to_world(id, screen_x, screen_y)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.screen_to_world() -> Camera does not exist: " .. id)
		return
	end
	if not is_within_viewport(rendy.cameras[id], screen_x, screen_y) then
		return
	end
	local camera_world_position = go.get_world_position(id)
	local dx_from_viewport = screen_x - rendy.cameras[id].viewport_px
	local dy_from_viewport = screen_y - rendy.cameras[id].viewport_py
	local viewport_width_compression = 1 / rendy.cameras[id].viewport_width
	local viewport_height_compression = 1 / rendy.cameras[id].viewport_height
	local resolution_width_ratio = rendy.cameras[id].resolution_width / rendy.window_width
	local resolution_height_ratio = rendy.cameras[id].resolution_height / rendy.window_height
	if rendy.cameras[id].resize_mode_center or rendy.cameras[id].resize_mode_expand then
		local world_x = (dx_from_viewport - rendy.cameras[id].viewport_pw * 0.5) * viewport_width_compression * rendy.cameras[id].zoom
		local world_y = (dy_from_viewport - rendy.cameras[id].viewport_ph * 0.5) * viewport_height_compression * rendy.cameras[id].zoom
		return camera_world_position.x + world_x, camera_world_position.y + world_y
	elseif rendy.cameras[id].resize_mode_stretch then
		local world_x = (dx_from_viewport - rendy.cameras[id].viewport_pw * 0.5) * viewport_width_compression * resolution_width_ratio * rendy.cameras[id].zoom
		local world_y = (dy_from_viewport - rendy.cameras[id].viewport_ph * 0.5) * viewport_height_compression * resolution_height_ratio * rendy.cameras[id].zoom
		return camera_world_position.x + world_x, camera_world_position.y + world_y
	end
end

function rendy.world_to_screen(id, world_position)
	if not rendy.cameras[id] then
		print("Defold Rendy: rendy.screen_to_world() -> Camera does not exist: " .. id)
		return
	end
	local camera_world_position = go.get_world_position(id)
	if rendy.cameras[id].resize_mode_center or rendy.cameras[id].resize_mode_expand then
		
	elseif rendy.cameras[id].resize_mode_stretch then
		
	end
end

return rendy