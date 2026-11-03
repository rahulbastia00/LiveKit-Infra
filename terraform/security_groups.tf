resource "aws_security_group" "livekit_media" {
  name        = "${var.cluster_name}-livekit-media-sg"
  description = "Allow inbound signaling and WebRTC UDP ranges"
  vpc_id      = aws_vpc.main.id

  # Next.js / HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # LiveKit Signaling (TCP)
  ingress {
    description = "LiveKit Signaling"
    from_port   = 7880
    to_port     = 7881
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # LiveKit WebRTC Media Range (UDP)
  ingress {
    description = "LiveKit WebRTC Media"
    from_port   = 50000
    to_port     = 50050
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_name}-livekit-sg"
  }
}
