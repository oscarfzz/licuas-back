# Generated by Django 2.2.7 on 2020-02-06 09:44

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0005_auto_20200206_1035'),
    ]

    operations = [
        migrations.AlterField(
            model_name='obra',
            name='descripcion',
            field=models.TextField(help_text='descripcion de la obra', verbose_name='descripcion'),
        ),
    ]
