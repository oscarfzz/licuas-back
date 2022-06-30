# Generated by Django 2.2.7 on 2020-02-07 13:38

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0009_insertar_grupos'),
    ]

    operations = [
        migrations.AlterField(
            model_name='grupo',
            name='nombre',
            field=models.CharField(db_column='nombre', help_text='Nombre de la grupo', max_length=255, unique=True, verbose_name='nombre'),
        ),
    ]