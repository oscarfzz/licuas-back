# Generated by Django 2.2.7 on 2020-02-07 13:28

from django.db import migrations

GRUPOS = []


def insertar_grupos(apps, schema_editor):
    Grupo = apps.get_model('general', 'Grupo')
    for grupo in GRUPOS:
        instancia = Grupo(nombre=grupo)
        instancia.save()


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0008_auto_20200207_0842'),
    ]

    operations = [
        migrations.RunPython(insertar_grupos),
    ]
