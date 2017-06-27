# Collaborative editing
#
# 1. document is put in edit mode, counter = 0
# 2. each client receives the counter
# 3. counter is sent with every operation
# 4. on receive, counter is set to received value
#
# server:
#
# queue operations, apply in order
#
# if op counter < previous counter
#   apply transformation
# else
#   apply op
# end
#
