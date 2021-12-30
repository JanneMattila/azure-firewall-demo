##################################
#     _           _____
#    / \    ____ |  ___|_      __
#   / _ \  |_  / | |_  \ \ /\ / /
#  / ___ \  / /  |  _|  \ V  V /
# /_/   \_\/___| |_|     \_/\_/
# demo script
##################################

# Run deployment
Set-Location .\deploy\
.\deploy.ps1
# Few notes: 
# - Same deployment can be executed in pipeline
#   by Azure AD Service Principal
# - Deployment takes roughly nn minutes
#

##################################
#  ____  _
# |  _ \| | __ _ _   _
# | |_) | |/ _` | | | |
# |  __/| | (_| | |_| |
# |_|   |_|\__,_|\__, |
#                |___/
# with our setup
##################################

# To be added

##################################
#   ____ _
#  / ___| | ___  __ _ _ __
# | |   | |/ _ \/ _` | '_ \
# | |___| |  __/ (_| | | | |
#  \____|_|\___|\__,_|_| |_|
# up demo resources 
##################################

Remove-AzResourceGroup -Name "rg-azure-firewall-demo" -Force
