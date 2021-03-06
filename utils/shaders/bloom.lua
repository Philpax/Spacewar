Bloom = {}

local lastCanvas

local canvas
local pass1
local pass2

function Bloom.reset()
	canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
	-- If I were being more conventional I could use this + texture quads to make ships wrap around the screen
	-- canvas:setWrap('repeat')

	pass1 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
	pass1:setWrap('mirroredrepeat')

	pass2 = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight(), 'rgba4')
	pass2:setWrap('mirroredrepeat')

	Assets.shaders.blur:send('canvas_size', {love.graphics.getDimensions()})
	Assets.shaders.blur:send('blur_amount', 25)
	Assets.shaders.blur:send('blur_scale', 2)
	Assets.shaders.blur:send('blur_strength', 0.25)
end

function Bloom.preDraw()
	lastCanvas = love.graphics.getCanvas()

	love.graphics.setCanvas(canvas)
end

function Bloom.postDraw()
	love.graphics.setCanvas(lastCanvas)

	lastCanvas = love.graphics.getCanvas()

	pass1:clear()
	pass2:clear()

	love.graphics.push('all')
		love.graphics.setShader(Assets.shaders.blur)
		Assets.shaders.blur:send('horizontal', true)

		love.graphics.setCanvas(pass1)
		love.graphics.draw(canvas)

		Assets.shaders.blur:send('horizontal', false)

		love.graphics.setCanvas(pass2)
		love.graphics.draw(pass1)
	love.graphics.pop()

	love.graphics.setCanvas(lastCanvas)
	love.graphics.draw(canvas)

	love.graphics.push('all')
		love.graphics.setBlendMode('additive')
		love.graphics.draw(pass2)
	love.graphics.pop()

	canvas:clear()
end

return Bloom
