# Generated by Django 2.2.7 on 2020-02-07 14:04

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0018_insertar_ambitos'),
    ]

    operations = [
        migrations.AlterField(
            model_name='clasificacion_gto',
            name='nombre',
            field=models.CharField(db_column='nombre', help_text='Nombre de la ambito', max_length=255, unique=True, verbose_name='nombre'),
        ),
    ]