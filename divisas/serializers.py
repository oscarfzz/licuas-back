from rest_framework import serializers
from divisas.models import Divisa


class DivisaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Divisa
        fields = "__all__"
