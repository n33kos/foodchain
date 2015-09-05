class Numeric
  def clamp min, max
    [[self, max].min, min].max
  end
end

def detectcollisions x1,y1,s1,x2,y2,s2
	xdist = (x2-x1).abs
	ydist = (y2-y1).abs
	if xdist <= (s1+s2)/2 && ydist <= (s1+s2)/2
		return true
	else
		return false
	end
end

def calculateQuadrant x,y,width,height
	halfWidth = width/2
	halfHeight = height/2
	if x < halfWidth && y < halfHeight
		return 0
	elsif x > halfWidth && y < halfHeight
		return 1
	elsif x < halfWidth && y > halfHeight
		return 2
	elsif x > halfWidth && y > halfHeight
		return 3
	end
end

def calculateSubQuadrant x,y,width,quadrant
	halfWidth = width/2
	quarterWidth = halfWidth/4
	if quadrant == 1 or quadrant == 3
		quarterWidth = (halfWidth/4)+halfWidth
	end

	if x < quarterWidth
		return 0
	elsif x < quarterWidth*2
		return 1
	elsif x < quarterWidth*3
		return 2
	else
		return 3
	end
end