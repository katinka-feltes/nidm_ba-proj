(pwd() != @__DIR__) && cd(@__DIR__) # allow starting app from bin/ dir

using NIDM
const UserApp = NIDM
NIDM.main()
