# Generated by Django 2.2.7 on 2022-07-14 16:51

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('hdr', '0019_hojaderutapagoauxiliar'),
    ]

    operations = [
        migrations.AddField(
            model_name='hojaderutapago',
            name='pago_actualizar',
            field=models.BooleanField(default=True),
        ),
    ]
