# Generated by Django 2.2.7 on 2020-02-07 14:13

from django.db import migrations

UNIDADES = []


def insertar_unidades_organizativas(apps, schema_editor):
    UnidadOrganizativa = apps.get_model('general', 'UnidadOrganizativa')
    for madre in UNIDADES:
        instancia_madre = UnidadOrganizativa(descripcion=madre["nombre"])
        instancia_madre.save()
        for hija in madre["hijas"]:
            instancia_hija = UnidadOrganizativa(
                descripcion=hija, padre=instancia_madre)
            instancia_hija.save()


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0021_auto_20200207_1509'),
    ]

    operations = [
        migrations.RunPython(insertar_unidades_organizativas),
    ]
